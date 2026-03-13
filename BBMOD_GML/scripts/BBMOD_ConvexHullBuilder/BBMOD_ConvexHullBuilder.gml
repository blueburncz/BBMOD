/// @module Physics

/// @func BBMOD_ConvexHullBuilder(_physicsEngine)
///
/// @desc A helper class for creating convex hull collision shapes from BBMOD
/// models. This builder handles the complexity of traversing the model's node
/// hierarchy, applying transforms, and generating an optimized convex hull.
///
/// @param {Struct.BBMOD_PhysicsEngine} _physicsEngine The physics engine
/// instance to use for creating shapes.
///
/// @example
/// ```gml
/// // Load a model (must not be frozen to access vertex data)
/// var model = new BBMOD_Model("character.bbmod");
/// model.freeze(false); // Ensure vertex data is available on CPU
///
/// // Create convex hull from the entire model
/// var builder = new BBMOD_ConvexHullBuilder(physicsEngine);
/// var hullShape = builder.from_model(model);
///
/// // Use the hull in a rigid body
/// var rigidBodyInfo = new BBMOD_RigidBodyInfo();
/// rigidBodyInfo.Shape = hullShape;
/// rigidBodyInfo.Mass = 50.0;
/// var rigidBody = physicsWorld.create_rigid_body(rigidBodyInfo);
/// ```
///
/// @see BBMOD_PhysicsEngine
/// @see BBMOD_ConvexHullPhysicsShape
/// @see BBMOD_Model
function BBMOD_ConvexHullBuilder(_physicsEngine) constructor
{
	/// @var {Struct.BBMOD_PhysicsEngine} The physics engine instance.
	PhysicsEngine = _physicsEngine;

	/// @func from_model(_model)
	///
	/// @desc Creates a convex hull collision shape from an entire BBMOD model.
	/// This function traverses the model's node hierarchy, applies all node
	/// transforms (respecting the dual quaternion transform chain), and
	/// generates a single convex hull that encompasses all transformed vertices.
	///
	/// @param {Struct.BBMOD_Model} _model The model to create a convex hull
	/// from. The model must not be frozen (frozen models don't have vertex
	/// data available on the CPU). Do not call `model.freeze()` on models
	/// you intend to use for convex hull generation.
	///
	/// @return {Struct.BBMOD_ConvexHullPhysicsShape} The created convex hull
	/// shape, or `undefined` if creation failed (e.g., model is frozen or has
	/// no vertices).
	///
	/// @throws {String} Assertion error if the model is frozen.
	///
	/// @note The returned convex hull is automatically optimized using Bullet's
	/// btShapeHull simplification algorithm to reduce the number of vertices
	/// while maintaining an accurate collision approximation.
	///
	/// @note All vertex transformations are performed in C++ for optimal
	/// performance.
	static from_model = function (_model)
	{
		// Validate model state
		if (_model.Frozen)
		{
			bbmod_assert(false, "Cannot create convex hull from frozen model!");
			return undefined;
		}

		// Create buffer for transferring data to C++
		var _buffer = buffer_create(1024, buffer_grow, 1);

		// Write mesh count
		buffer_write(_buffer, buffer_u32, array_length(_model.Meshes));

		// Write all mesh vertex data
		for (var i = 0; i < array_length(_model.Meshes); ++i)
		{
			var _mesh = _model.Meshes[i];
			var _vertexBuffer = _mesh.VertexBuffer;

			// Skip meshes with no vertex buffer or frozen meshes
			if (_vertexBuffer == undefined || _mesh.Frozen)
			{
				buffer_write(_buffer, buffer_u32, 0);
				continue;
			}

			// Get vertex count
			var _vertexCount = vertex_get_number(_vertexBuffer);
			buffer_write(_buffer, buffer_u32, _vertexCount);

			// Extract vertex data from GPU buffer
			var _vbuffer = buffer_create_from_vertex_buffer(_vertexBuffer, buffer_fixed, 1);
			var _stride = _mesh.VertexFormat.get_byte_size();
			var _offset = 0;

			// Write vertex positions (x, y, z)
			// Vertex positions are always the first 3 floats in the vertex format
			for (var j = 0; j < _vertexCount; ++j)
			{
				var _x = buffer_peek(_vbuffer, _offset, buffer_f32);
				var _y = buffer_peek(_vbuffer, _offset + 4, buffer_f32);
				var _z = buffer_peek(_vbuffer, _offset + 8, buffer_f32);

				buffer_write(_buffer, buffer_f64, _x);
				buffer_write(_buffer, buffer_f64, _y);
				buffer_write(_buffer, buffer_f64, _z);

				_offset += _stride;
			}

			buffer_delete(_vbuffer);
		}

		// Write node hierarchy (starting from root)
		__write_node(_buffer, _model.RootNode);

		// Call C++ function to build convex hull
		var _shapeId = BBMOD_ConvexHull_CreateFromModel(buffer_get_address(_buffer));

		// Clean up buffer
		buffer_delete(_buffer);

		// Check for error
		if (_shapeId < 0)
		{
			bbmod_assert(false, "Failed to create convex hull from model!");
			return undefined;
		}

		// Create shape wrapper
		var _shape = new BBMOD_ConvexHullPhysicsShape();
		_shape.__id = _shapeId;
		return _shape;
	};

	/// @func __write_node(_buffer, _node)
	///
	/// @desc Recursively writes a node and its children to the buffer in
	/// depth-first order. This is used internally to serialize the model's
	/// node hierarchy for transfer to C++.
	///
	/// @param {Id.Buffer} _buffer The buffer to write to.
	/// @param {Struct.BBMOD_Node} _node The node to write.
	///
	/// @private
	static __write_node = function (_buffer, _node)
	{
		// Write dual quaternion transform (8 doubles: real quaternion + dual quaternion)
		var _dq = _node.Transform;
		buffer_write(_buffer, buffer_f64, _dq.Real.X);
		buffer_write(_buffer, buffer_f64, _dq.Real.Y);
		buffer_write(_buffer, buffer_f64, _dq.Real.Z);
		buffer_write(_buffer, buffer_f64, _dq.Real.W);
		buffer_write(_buffer, buffer_f64, _dq.Dual.X);
		buffer_write(_buffer, buffer_f64, _dq.Dual.Y);
		buffer_write(_buffer, buffer_f64, _dq.Dual.Z);
		buffer_write(_buffer, buffer_f64, _dq.Dual.W);

		// Write mesh indices (which meshes this node draws)
		var _meshes = _node.Meshes ?? [];
		buffer_write(_buffer, buffer_u32, array_length(_meshes));
		for (var i = 0; i < array_length(_meshes); ++i)
		{
			buffer_write(_buffer, buffer_u32, _meshes[i]);
		}

		// Write children recursively
		var _children = _node.Children ?? [];
		buffer_write(_buffer, buffer_u32, array_length(_children));
		for (var i = 0; i < array_length(_children); ++i)
		{
			__write_node(_buffer, _children[i]);
		}
	};

	/// @func save_to_file(_shape, _filepath)
	///
	/// @desc Saves a convex hull collision shape to a binary file for later
	/// loading. This allows you to generate convex hulls once at development
	/// time and load them quickly at runtime without regenerating.
	///
	/// @param {Struct.BBMOD_ConvexHullPhysicsShape} _shape The convex hull
	/// shape to save.
	/// @param {String} _filepath The path to save the file to (relative to
	/// the game directory or absolute path).
	///
	/// @return {Bool} Returns `true` if the save was successful, `false`
	/// otherwise.
	///
	/// @example
	/// ```gml
	/// // Generate hull once at development time
	/// var builder = new BBMOD_ConvexHullBuilder(physicsEngine);
	/// var hull = builder.from_model(characterModel);
	///
	/// // Save it to a file
	/// if (builder.save_to_file(hull, "Data/Hulls/character.hull"))
	/// {
	///     show_debug_message("Hull saved successfully!");
	/// }
	/// ```
	///
	/// @see BBMOD_ConvexHullBuilder.load_from_file
	static save_to_file = function (_shape, _filepath)
	{
		gml_pragma("forceinline");
		var _result = BBMOD_ConvexHull_SaveToFile(_shape.__id, _filepath);
		return (_result >= 0);
	};

	/// @func load_from_file(_filepath)
	///
	/// @desc Loads a convex hull collision shape from a binary file that was
	/// previously saved with `save_to_file()`. This is much faster than
	/// regenerating the hull from the model.
	///
	/// @param {String} _filepath The path to load the file from (relative to
	/// the game directory or absolute path).
	///
	/// @return {Struct.BBMOD_ConvexHullPhysicsShape} The loaded convex hull
	/// shape, or `undefined` if loading failed.
	///
	/// @example
	/// ```gml
	/// // Load pre-saved hull at runtime
	/// var builder = new BBMOD_ConvexHullBuilder(physicsEngine);
	/// var hull = builder.load_from_file("Data/Hulls/character.hull");
	///
	/// if (hull != undefined)
	/// {
	///     // Use the hull in a rigid body
	///     var rigidBodyInfo = new BBMOD_RigidBodyInfo();
	///     rigidBodyInfo.PhysicsShape = hull;
	///     rigidBodyInfo.Mass = 50.0;
	///     var rigidBody = physicsWorld.create_rigid_body(rigidBodyInfo);
	/// }
	/// ```
	///
	/// @see BBMOD_ConvexHullBuilder.save_to_file
	static load_from_file = function (_filepath)
	{
		gml_pragma("forceinline");
		var _shapeId = BBMOD_ConvexHull_LoadFromFile(_filepath);

		if (_shapeId < 0)
		{
			return undefined;
		}

		var _shape = new BBMOD_ConvexHullPhysicsShape();
		_shape.__id = _shapeId;
		return _shape;
	};
}
