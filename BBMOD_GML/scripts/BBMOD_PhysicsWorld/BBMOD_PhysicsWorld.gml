/// @module Physics

// TODO: Replace Bullet-specific debug modes with mapping to BBMOD debug modes.

/// @enum Enumeration representing debug draw modes for rendering debug
/// information.
enum btDebugDrawModes
{
	/// @member No debug drawing.
	DBG_NoDebug = 0,
		/// @member Debug drawing of wireframe.
		DBG_DrawWireframe = 1,
		/// @member Debug drawing of axis-aligned bounding boxes (AABBs).
		DBG_DrawAabb = 2,
		/// @member Debug drawing of features as text.
		DBG_DrawFeaturesText = 4,
		/// @member Debug drawing of contact points.
		DBG_DrawContactPoints = 8,
		/// @member Debug drawing with no deactivation.
		DBG_NoDeactivation = 16,
		/// @member Debug drawing with no help text.
		DBG_NoHelpText = 32,
		/// @member Debug drawing of text.
		DBG_DrawText = 64,
		/// @member Debug drawing of profile timings.
		DBG_ProfileTimings = 128,
		/// @member Debug enabling of Separating Axis Theorem (SAT) comparison.
		DBG_EnableSatComparison = 256,
		/// @member Debug disabling of Bullet's Linear Complementarity Problem (LCP).
		DBG_DisableBulletLCP = 512,
		/// @member Debug enabling of Continuous Collision Detection (CCD).
		DBG_EnableCCD = 1024,
		/// @member Debug drawing of constraints.
		DBG_DrawConstraints = 0b100000000000,
		/// @member Debug drawing of constraint limits.
		DBG_DrawConstraintLimits = 0b1000000000000,
		/// @member Debug drawing of wireframe in a fast manner.
		DBG_FastWireframe = 0b10000000000000,
		/// @member Debug drawing of normals.
		DBG_DrawNormals = 0b100000000000000,
		/// @member Debug drawing of frames.
		DBG_DrawFrames = 0b1000000000000000,
		/// @member Maximum debug draw mode.
		DBG_MAX_DEBUG_DRAW_MODE
};

/// @func BBMOD_PhysicsWorldInfo()
///
/// @desc A struct that contains information for creating a physics world.
///
/// @see BBMOD_PhysicsEngine.create_physics_world
/// @see BBMOD_PhysicsWorld
function BBMOD_PhysicsWorldInfo() constructor
{
	/// @var {Struct.BBMOD_Vec3} The gravity vector for the physics world.
	/// Defaults to `(0, 0, -9.81)`.
	Gravity = new BBMOD_Vec3(0.0, 0.0, -9.81);

	/// @var {Real} The debug mode for the physics world. Defaults to `0` (no
	/// debug drawing).
	/// @see btDebugDrawModes
	DebugMode = 0;

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the physics world info into given buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_PhysicsWorldInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		Gravity.ToBuffer(_buffer, buffer_f64);
		buffer_write(_buffer, buffer_u64, DebugMode);
		return self;
	};

	/// @func to_abi()
	///
	/// @desc Converts the physics world info to a format suitable for passing
	/// to the native physics engine. This is used internally when creating a
	/// physics world, and is not intended to be called directly by user code.
	///
	/// @return {Pointer} The address of the buffer containing the physics
	/// world info.
	static to_abi = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		to_buffer(_scratchBuffer);
		return buffer_get_address(_scratchBuffer);
	};
}

/// @func BBMOD_PhysicsWorld()
///
/// @desc A struct that represents a physics world. It provides methods for
/// creating rigid bodies, constraints, and other physics-related objects, as well as simulating
/// the physics world and drawing debug information.
///
/// @see BBMOD_PhysicsEngine.create_physics_world
function BBMOD_PhysicsWorld() constructor
{
	__id = -1;

	/// @func get_gravity()
	///
	/// @desc Gets the gravity vector for the physics world.
	///
	/// @return {Struct.BBMOD_Vec3} The gravity vector for the physics world.
	static get_gravity = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		BBMOD_PhysicsWorld_GetGravity(__id, buffer_get_address(_scratchBuffer));
		return new BBMOD_Vec3().FromBuffer(_scratchBuffer, buffer_f64);
	};

	/// @func set_gravity(_gravity)
	///
	/// @desc Sets the gravity vector for the physics world.
	///
	/// @param {Struct.BBMOD_Vec3} _gravity The new gravity vector.
	///
	/// @return {Struct.BBMOD_PhysicsWorld} Returns `self`.
	static set_gravity = function (_gravity)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_gravity.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_PhysicsWorld_SetGravity(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func create_rigid_body(_info)
	///
	/// @desc Creates a new rigid body in the physics world with the specified
	/// information.
	///
	/// @param {Struct.BBMOD_RigidBodyInfo} _info Information for creating the
	/// rigid body.
	///
	/// @return {Struct.BBMOD_RigidBody} The created rigid body.
	static create_rigid_body = function (_info)
	{
		gml_pragma("forceinline");
		var _rigidBody = new BBMOD_RigidBody();
		_rigidBody.__id = BBMOD_PhysicsWorld_CreateRigidBody(__id, _info.to_abi());
		_rigidBody.__physicsWorld = self;
		return _rigidBody;
	};

	/// @func create_constraint(_info)
	///
	/// @desc Creates a new constraint in the physics world with the
	/// specified information.
	///
	/// @param {Struct.BBMOD_PhysicsConstraintInfo} _info Information for
	/// creating the constraint.
	///
	/// @return {Struct.BBMOD_PhysicsConstraint} The created constraint.
	static create_constraint = function (_info)
	{
		gml_pragma("forceinline");

		var _constraint = undefined;
		switch (_info.Type)
		{
			case BBMOD_EPhysicsConstraintType.ConeTwist:
				_constraint = new BBMOD_ConeTwistPhysicsConstraint();
				break;

			case BBMOD_EPhysicsConstraintType.Hinge:
				_constraint = new BBMOD_HingePhysicsConstraint();
				break;

			case BBMOD_EPhysicsConstraintType.Point:
				_constraint = new BBMOD_PointPhysicsConstraint();
				break;

			case BBMOD_EPhysicsConstraintType.SixDOF:
				_constraint = new BBMOD_SixDOFPhysicsConstraint();
				break;

			case BBMOD_EPhysicsConstraintType.Slider:
				_constraint = new BBMOD_SliderPhysicsConstraint();
				break;

			default:
				bbmod_assert(false, $"Invalid constraint type: {_info.__type}!");
				break;
		}

		_constraint.__id = BBMOD_PhysicsWorld_CreateConstraint(__id, _info.to_abi());
		_constraint.__physicsWorld = self;

		return _constraint;
	};

	/// @function create_terrain(_terrain)
	///
	/// @desc Creates a physical representation of the given terrain in the
	/// physics world.
	///
	/// @param {Struct.BBMOD_Terrain} _terrain The terrain to create the physics
	/// terrain from.
	///
	/// @return {Struct.BBMOD_PhysicsTerrain} The created physics terrain.
	static create_terrain = function (_terrain)
	{
		gml_pragma("forceinline");

		var _terrainWidth = _terrain.Size.X;
		var _terrainHeight = _terrain.Size.Y;

		var _buffer = buffer_create(1, buffer_grow, 1);
		buffer_write(_buffer, buffer_u32, _terrainWidth);
		buffer_write(_buffer, buffer_u32, _terrainHeight);
		buffer_write(_buffer, buffer_f64, _terrain.Position.X);
		buffer_write(_buffer, buffer_f64, _terrain.Position.Y);
		buffer_write(_buffer, buffer_f64, _terrain.Position.Z);
		buffer_write(_buffer, buffer_f64, _terrain.Scale.X);
		buffer_write(_buffer, buffer_f64, _terrain.Scale.Y);
		buffer_write(_buffer, buffer_f64, _terrain.Scale.Z);

		var _j = 0;
		repeat(_terrainHeight)
		{
			var _i = 0;
			repeat(_terrainWidth)
				{
					var _val = _terrain.get_height_index(_i, _j);
					buffer_write(_buffer, buffer_u8, _val);
					++_i;
				}
				++_j;
		}

		var _physicsTerrain = new BBMOD_PhysicsTerrain();
		_physicsTerrain.__id = BBMOD_PhysicsWorld_CreateTerrain(__id, buffer_get_address(_buffer));
		_physicsTerrain.__physicsWorld = self;
		_physicsTerrain.__buffer = _buffer;
		return _physicsTerrain;
	};

	/// @function create_vehicle(_info)
	///
	/// @desc Creates a new vehicle in the physics world with the specified
	/// information.
	///
	/// @param {Struct.BBMOD_PhysicsVehicleInfo} _info Information for creating
	/// the vehicle.
	///
	/// @return {Struct.BBMOD_PhysicsVehicle} The created physics vehicle.
	static create_vehicle = function (_info)
	{
		gml_pragma("forceinline");
		var _vehicle = new BBMOD_PhysicsVehicle();
		_vehicle.__id = BBMOD_PhysicsWorld_CreateVehicle(__id, _info.to_abi());
		_vehicle.__physicsWorld = self;
		return _vehicle;
	};

	/// @function create_character_controller(_info)
	///
	/// @desc Creates a kinematic character controller for first/third
	/// person character movement. The character controller provides ground
	/// detection, jumping, slope handling, and automatic step climbing.
	///
	/// @param {Struct.BBMOD_CharacterControllerInfo} _info Information for
	/// creating the character controller.
	///
	/// @return {Struct.BBMOD_CharacterController} The created character
	/// controller.
	///
	/// @example
	/// ```gml
	/// // Create a character controller
	/// var _info = new BBMOD_CharacterControllerInfo();
	/// _info.Radius = 0.5;
	/// _info.Height = 1.8;
	/// _info.StepHeight = 0.35;
	/// _info.Position = new BBMOD_Vec3(x, y, z);
	///
	/// characterController = physicsWorld.create_character_controller(_info);
	/// characterController.set_fall_speed(55.0);
	/// characterController.set_jump_speed(10.0);
	/// characterController.set_max_slope(degtorad(45));
	/// ```
	static create_character_controller = function (_info)
	{
		gml_pragma("forceinline");
		var _characterController = new BBMOD_CharacterController();
		_characterController.__id = BBMOD_PhysicsWorld_CreateCharacterController(__id, _info.to_abi());
		_characterController.__physicsWorld = self;
		return _characterController;
	};

	/// @func create_ragdoll(_ragdollInfo, _worldTransform)
	///
	/// @desc Creates a physics ragdoll from a ragdoll definition. The ragdoll
	/// will contain rigid bodies for each defined part and constraints
	/// connecting them based on the bone hierarchy.
	///
	/// @param {Struct.BBMOD_RagdollInfo} _ragdollInfo The ragdoll definition
	/// containing all body parts and their properties.
	/// @param {Struct.BBMOD_Matrix} _worldTransform The initial world transform
	/// for the ragdoll. This is typically a simple translation to position the
	/// ragdoll in the world.
	///
	/// @return {Struct.BBMOD_Ragdoll} The created ragdoll, or `undefined` if
	/// creation failed.
	///
	/// @example
	/// ```gml
	/// var ragdollInfo = new BBMOD_RagdollInfo(characterModel);
	/// // ... add parts ...
	///
	/// var ragdoll = physicsWorld.create_ragdoll(
	///     ragdollInfo,
	///     new BBMOD_Matrix().TranslateSelf(x, y, z)
	/// );
	/// ```
	///
	/// @see BBMOD_RagdollInfo
	/// @see BBMOD_Ragdoll
	static create_ragdoll = function (_ragdollInfo, _worldTransform)
	{
		gml_pragma("forceinline");

		// GML writes ragdoll definition, C++ reads it
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_ragdollInfo.to_buffer(_scratchBuffer, _worldTransform);

		var _ragdollId = BBMOD_PhysicsWorld_CreateRagdoll(__id, buffer_get_address(_scratchBuffer));

		if (_ragdollId < 0)
		{
			return undefined;
		}

		var _ragdoll = new BBMOD_Ragdoll();
		_ragdoll.__id = _ragdollId;
		_ragdoll.__physicsWorld = self;
		_ragdoll.__model = _ragdollInfo.Model;
		_ragdoll.__transformArray = array_create(_ragdollInfo.Model.BoneCount * 8, 0);

		return _ragdoll;
	};

	/// @func simulate(_timeStep[, _maxSubSteps])
	///
	/// @desc Simulates the physics world for the given time step.
	///
	/// @param {Real} _timeStep The time step to simulate the physics world for.
	/// @param {Real} [_maxSubSteps] The maximum number of sub-steps to perform.
	/// Defaults to `1`.
	///
	/// @return {Struct.BBMOD_PhysicsWorld} Returns `self`.
	static simulate = function (_timeStep, _maxSubSteps = 1)
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsWorld_Simulate(__id, _timeStep, _maxSubSteps);
		return self;
	};

	////////////////////////////////////////////////////////////////////////////////
	//
	// Collision Queries
	//

	/// @func raycast(_from, _to)
	///
	/// @desc Performs a raycast from one point to another and returns the
	/// closest hit. This is the most common collision query, useful for shooting,
	/// ground detection, line-of-sight checks, and more.
	///
	/// @param {Struct.BBMOD_Vec3} _from The starting point of the ray in world space.
	/// @param {Struct.BBMOD_Vec3} _to The ending point of the ray in world space.
	///
	/// @return {Struct.BBMOD_PhysicsRaycastResult} A struct containing hit information.
	/// Check the `Hit` property to see if anything was hit.
	///
	/// @example
	/// ```gml
	/// // Check if player is on ground
	/// var _from = new BBMOD_Vec3(player.x, player.y, player.z);
	/// var _to = new BBMOD_Vec3(player.x, player.y, player.z - 10);
	/// var _result = physicsWorld.raycast(_from, _to);
	///
	/// if (_result.Hit)
	/// {
	///     // Player is on ground
	///     show_debug_message("Ground at: " + string(_result.Position.Z));
	/// }
	/// ```
	static raycast = function (_from, _to)
	{
		gml_pragma("forceinline");

		// Prepare buffer: write ray start and end, reserve space for result
		var _scratchBuffer = bbmod_get_scratch_buffer(
			buffer_sizeof(buffer_f64) * 6 +  // Input: from (3) + to (3)
			buffer_sizeof(buffer_f64) * 8     // Output: hit(1) + pos(3) + normal(3) + fraction(1)
		);

		// Write ray start and end
		_from.ToBuffer(_scratchBuffer, buffer_f64);
		_to.ToBuffer(_scratchBuffer, buffer_f64);

		// Perform raycast
		BBMOD_PhysicsWorld_Raycast(__id, buffer_get_address(_scratchBuffer));

		// Read results
		var _result = new BBMOD_PhysicsRaycastResult();
		var _hit = buffer_read(_scratchBuffer, buffer_f64);

		if (_hit > 0.5)
		{
			_result.Hit = true;

			// Read hit position
			_result.Position.X = buffer_read(_scratchBuffer, buffer_f64);
			_result.Position.Y = buffer_read(_scratchBuffer, buffer_f64);
			_result.Position.Z = buffer_read(_scratchBuffer, buffer_f64);

			// Read hit normal
			_result.Normal.X = buffer_read(_scratchBuffer, buffer_f64);
			_result.Normal.Y = buffer_read(_scratchBuffer, buffer_f64);
			_result.Normal.Z = buffer_read(_scratchBuffer, buffer_f64);

			// Read hit fraction
			_result.Fraction = buffer_read(_scratchBuffer, buffer_f64);

			// Read body ID
			var _bodyId = buffer_read(_scratchBuffer, buffer_f64);
			if (_bodyId >= 0)
			{
				_result.BodyId = _bodyId;
			}
		}
		else
		{
			_result.Hit = false;
		}

		return _result;
	};

	/// @func shape_sweep(_shape, _fromTransform, _toTransform)
	///
	/// @desc Performs a convex shape sweep (cast) from one transform to another
	/// and returns the closest hit. This is useful for predicting collisions of
	/// moving objects, advanced character controllers, vehicle suspension, and
	/// projectile paths.
	///
	/// @param {Struct.BBMOD_PhysicsShape} _shape The convex shape to sweep. Must be
	/// a convex shape (Box, Sphere, Capsule, Cylinder, Cone, or ConvexHull). Static
	/// mesh shapes and compound shapes are not supported for sweeping.
	/// @param {Struct.BBMOD_Matrix} _fromTransform The starting transform (position
	/// and rotation) of the shape in world space.
	/// @param {Struct.BBMOD_Matrix} _toTransform The ending transform (position
	/// and rotation) of the shape in world space.
	///
	/// @return {Struct.BBMOD_PhysicsSweepResult} A struct containing hit information.
	/// Check the `Hit` property to see if anything was hit. Returns a non-hit
	/// result if the shape is not convex.
	///
	/// @example
	/// ```gml
	/// // Predict where a moving sphere will collide
	/// var _sphereShape = physicsWorld.create_shape(new BBMOD_SpherePhysicsShapeInfo(10));
	/// var _fromMatrix = new BBMOD_Matrix().Translate(player.x, player.y, player.z);
	/// var _toMatrix = new BBMOD_Matrix().Translate(player.x + velocityX, player.y + velocityY, player.z);
	/// var _result = physicsWorld.shape_sweep(_sphereShape, _fromMatrix, _toMatrix);
	///
	/// if (_result.Hit)
	/// {
	///     // Collision will occur at this position
	///     show_debug_message("Will hit at: " + string(_result.Position));
	///     show_debug_message("Hit fraction: " + string(_result.Fraction)); // 0.0 to 1.0
	/// }
	/// ```
	static shape_sweep = function (_shape, _fromTransform, _toTransform)
	{
		gml_pragma("forceinline");

		// Prepare buffer: write shape ID + from matrix (16) + to matrix (16), reserve space for result (8)
		var _scratchBuffer = bbmod_get_scratch_buffer(
			buffer_sizeof(buffer_f64) * 1 +   // Input: shape ID
			buffer_sizeof(buffer_f64) * 16 +  // Input: from transform matrix
			buffer_sizeof(buffer_f64) * 16 +  // Input: to transform matrix
			buffer_sizeof(buffer_f64) * 8     // Output: hit(1) + pos(3) + normal(3) + fraction(1) + bodyId(1)
		);

		// Write shape ID
		buffer_write(_scratchBuffer, buffer_f64, _shape.__id);

		// Write from transform matrix
		_fromTransform.ToBuffer(_scratchBuffer, buffer_f64);

		// Write to transform matrix
		_toTransform.ToBuffer(_scratchBuffer, buffer_f64);

		// Perform shape sweep
		BBMOD_PhysicsWorld_ShapeSweep(__id, buffer_get_address(_scratchBuffer));

		// Read results
		var _result = new BBMOD_PhysicsSweepResult();
		var _hit = buffer_read(_scratchBuffer, buffer_f64);

		if (_hit > 0.5)
		{
			_result.Hit = true;

			// Read hit position
			_result.Position.X = buffer_read(_scratchBuffer, buffer_f64);
			_result.Position.Y = buffer_read(_scratchBuffer, buffer_f64);
			_result.Position.Z = buffer_read(_scratchBuffer, buffer_f64);

			// Read hit normal
			_result.Normal.X = buffer_read(_scratchBuffer, buffer_f64);
			_result.Normal.Y = buffer_read(_scratchBuffer, buffer_f64);
			_result.Normal.Z = buffer_read(_scratchBuffer, buffer_f64);

			// Read hit fraction
			_result.Fraction = buffer_read(_scratchBuffer, buffer_f64);

			// Read body ID
			var _bodyId = buffer_read(_scratchBuffer, buffer_f64);
			if (_bodyId >= 0)
			{
				_result.BodyId = _bodyId;
			}
		}
		else
		{
			_result.Hit = false;
		}

		return _result;
	};

	/// @func test_contact(_body1, _body2)
	///
	/// @desc Tests whether two rigid bodies are currently in contact.
	/// This is useful for trigger volumes, collision detection between
	/// specific objects, and conditional gameplay logic.
	///
	/// @param {Struct.BBMOD_RigidBody} _body1 The first rigid body.
	/// @param {Struct.BBMOD_RigidBody} _body2 The second rigid body.
	///
	/// @return {Bool} Returns true if the bodies are in contact, false
	/// otherwise.
	///
	/// @example
	/// ```gml
	/// // Check if player is touching a collectible
	/// if (physicsWorld.test_contact(playerBody, collectibleBody))
	/// {
	///     // Player collected the item
	///     collectible_pickup(collectibleBody);
	/// }
	/// ```
	static test_contact = function (_body1, _body2)
	{
		gml_pragma("forceinline");

		// Prepare buffer: write body IDs
		var _scratchBuffer = bbmod_get_scratch_buffer(
			buffer_sizeof(buffer_f64) * 2  // Input: body1 ID, body2 ID
		);

		buffer_write(_scratchBuffer, buffer_f64, _body1.__id);
		buffer_write(_scratchBuffer, buffer_f64, _body2.__id);

		// Perform contact test
		var _result = BBMOD_PhysicsWorld_TestBodyContact(__id, buffer_get_address(_scratchBuffer));

		return (_result > 0.5);
	};

	/// @func overlap_shape(_shape, _transform[, _maxResults])
	///
	/// @desc Finds all rigid bodies that overlap with the given shape at
	/// the specified position and rotation. This is useful for area
	/// queries like explosion radius checks, spawn validation, or
	/// detecting all objects in a zone.
	///
	/// @param {Struct.BBMOD_PhysicsShape} _shape The shape to test for
	/// overlaps. Can be any physics shape.
	/// @param {Struct.BBMOD_Matrix} _transform The world transform
	/// (position and rotation) where the shape should be tested.
	/// @param {Real} [_maxResults] Maximum number of overlapping bodies
	/// to return. Defaults to `32`.
	///
	/// @return {Array<Real>} An array of rigid body IDs that overlap
	/// with the shape. Use these IDs to get the actual BBMOD_RigidBody
	/// instances if needed. Returns an empty array if no overlaps found.
	///
	/// @example
	/// ```gml
	/// // Find all objects in explosion radius
	/// var _explosionShape = physicsWorld.create_shape(
	///     new BBMOD_SpherePhysicsShapeInfo(explosionRadius)
	/// );
	/// var _transform = new BBMOD_Matrix().Translate(explosionX, explosionY, explosionZ);
	/// var _hitBodies = physicsWorld.overlap_shape(_explosionShape, _transform);
	///
	/// for (var i = 0; i < array_length(_hitBodies); i++)
	/// {
	///     var _bodyId = _hitBodies[i];
	///     // Apply damage to each body
	///     apply_explosion_damage(_bodyId, explosionDamage);
	/// }
	/// ```
	static overlap_shape = function (_shape, _transform, _maxResults = 32)
	{
		gml_pragma("forceinline");

		// Prepare buffer: shape ID + transform matrix + max results, plus space for results
		var _scratchBuffer = bbmod_get_scratch_buffer(
			buffer_sizeof(buffer_f64) * 1 +   // Input: shape ID
			buffer_sizeof(buffer_f64) * 16 +  // Input: transform matrix
			buffer_sizeof(buffer_f64) * 1 +   // Input: max results
			buffer_sizeof(buffer_f64) * (1 + _maxResults)  // Output: count + array of body IDs
		);

		// Write shape ID
		buffer_write(_scratchBuffer, buffer_f64, _shape.__id);

		// Write transform matrix
		_transform.ToBuffer(_scratchBuffer, buffer_f64);

		// Write max results
		buffer_write(_scratchBuffer, buffer_f64, _maxResults);

		// Perform overlap test
		var _count = BBMOD_PhysicsWorld_OverlapShape(__id, buffer_get_address(_scratchBuffer));

		// Read results
		var _bodies = array_create(_count);
		for (var i = 0; i < _count; i++)
		{
			_bodies[i] = buffer_read(_scratchBuffer, buffer_f64);
		}

		return _bodies;
	};

	/// @func query_radius(_position, _radius[, _maxResults])
	///
	/// @desc Queries the physics world for all rigid bodies within a
	/// spherical radius from a center point. This is useful for
	/// explosion damage detection, area-of-effect abilities, proximity
	/// detection, and nearby object queries.
	///
	/// @param {Struct.BBMOD_Vec3} _position The center position of the
	/// sphere query in world space.
	/// @param {Real} _radius The radius of the sphere in world units.
	/// @param {Real} [_maxResults] The maximum number of bodies to
	/// return. Defaults to 32. Set to 0 for unlimited results (not
	/// recommended for large worlds).
	///
	/// @return {Array<Real>} An array of rigid body IDs that are
	/// within the specified radius. Returns an empty array if no
	/// bodies are found.
	///
	/// @example
	/// ```gml
	/// // Find all objects within explosion radius
	/// var _explosionPos = new BBMOD_Vec3(playerX, playerY, playerZ);
	/// var _hitBodies = physicsWorld.query_radius(_explosionPos, 10.0);
	///
	/// for (var i = 0; i < array_length(_hitBodies); i++)
	/// {
	///     // Apply explosion force to each body
	///     var _bodyId = _hitBodies[i];
	///     // ... apply damage or force
	/// }
	/// ```
	static query_radius = function (_position, _radius, _maxResults = 32)
	{
		gml_pragma("forceinline");

		// Prepare buffer: position + radius + max results, plus space for results
		var _scratchBuffer = bbmod_get_scratch_buffer(
			buffer_sizeof(buffer_f64) * 3 +   // Input: center position (vec3)
			buffer_sizeof(buffer_f64) * 1 +   // Input: radius
			buffer_sizeof(buffer_f64) * 1 +   // Input: max results
			buffer_sizeof(buffer_f64) * (1 + _maxResults)  // Output: count + array of body IDs
		);

		// Write position
		_position.ToBuffer(_scratchBuffer, buffer_f64);

		// Write radius
		buffer_write(_scratchBuffer, buffer_f64, _radius);

		// Write max results
		buffer_write(_scratchBuffer, buffer_f64, _maxResults);

		// Perform radius query
		var _count = BBMOD_PhysicsWorld_QueryRadius(__id, buffer_get_address(_scratchBuffer));

		// Read results
		var _bodies = array_create(_count);
		for (var i = 0; i < _count; i++)
		{
			_bodies[i] = buffer_read(_scratchBuffer, buffer_f64);
		}

		return _bodies;
	};

	/// @func query_aabb(_min, _max[, _maxResults])
	///
	/// @desc Queries the physics world for all rigid bodies within an
	/// axis-aligned bounding box (AABB). This is useful for spatial
	/// partitioning, sector-based queries, room detection, and
	/// rectangular area queries.
	///
	/// @param {Struct.BBMOD_Vec3} _min The minimum corner of the AABB
	/// in world space (typically lower-left-back corner).
	/// @param {Struct.BBMOD_Vec3} _max The maximum corner of the AABB
	/// in world space (typically upper-right-front corner).
	/// @param {Real} [_maxResults] The maximum number of bodies to
	/// return. Defaults to 32. Set to 0 for unlimited results (not
	/// recommended for large worlds).
	///
	/// @return {Array<Real>} An array of rigid body IDs that overlap
	/// with the AABB. Returns an empty array if no bodies are found.
	///
	/// @example
	/// ```gml
	/// // Find all objects in a room
	/// var _roomMin = new BBMOD_Vec3(0, 0, 0);
	/// var _roomMax = new BBMOD_Vec3(100, 100, 50);
	/// var _bodiesInRoom = physicsWorld.query_aabb(_roomMin, _roomMax);
	///
	/// show_debug_message($"Found {array_length(_bodiesInRoom)} objects in room");
	/// ```
	static query_aabb = function (_min, _max, _maxResults = 32)
	{
		gml_pragma("forceinline");

		// Prepare buffer: min + max + max results, plus space for results
		var _scratchBuffer = bbmod_get_scratch_buffer(
			buffer_sizeof(buffer_f64) * 3 +   // Input: min position (vec3)
			buffer_sizeof(buffer_f64) * 3 +   // Input: max position (vec3)
			buffer_sizeof(buffer_f64) * 1 +   // Input: max results
			buffer_sizeof(buffer_f64) * (1 + _maxResults)  // Output: count + array of body IDs
		);

		// Write min position
		_min.ToBuffer(_scratchBuffer, buffer_f64);

		// Write max position
		_max.ToBuffer(_scratchBuffer, buffer_f64);

		// Write max results
		buffer_write(_scratchBuffer, buffer_f64, _maxResults);

		// Perform AABB query
		var _count = BBMOD_PhysicsWorld_QueryAABB(__id, buffer_get_address(_scratchBuffer));

		// Read results
		var _bodies = array_create(_count);
		for (var i = 0; i < _count; i++)
		{
			_bodies[i] = buffer_read(_scratchBuffer, buffer_f64);
		}

		return _bodies;
	};

	/// @func get_collisions()
	///
	/// @desc Returns an array of all active collisions in the physics
	/// world. This is called each frame to poll for collision events.
	/// Each collision is represented by a BBMOD_CollisionInfo struct
	/// containing the IDs of both bodies, the number of contact
	/// points, and the total impulse magnitude.
	///
	/// @return {Array<Struct.BBMOD_CollisionInfo>} An array of
	/// collision info structs. Returns an empty array if no collisions
	/// are active.
	///
	/// @example
	/// ```gml
	/// // Poll for all collisions each frame
	/// var _collisions = physicsWorld.get_collisions();
	///
	/// for (var i = 0; i < array_length(_collisions); i++)
	/// {
	///     var _collision = _collisions[i];
	///     show_debug_message($"Bodies {_collision.Body1Id} and {_collision.Body2Id} colliding!");
	///     show_debug_message($"Contact points: {_collision.ContactCount}");
	///     show_debug_message($"Impact strength: {_collision.TotalImpulse}");
	/// }
	/// ```
	///
	/// @see BBMOD_CollisionInfo
	static get_collisions = function ()
	{
		gml_pragma("forceinline");

		// Get number of collision manifolds
		var _count = BBMOD_PhysicsWorld_GetCollisionCount(__id);

		// Early exit if no collisions
		if (_count <= 0)
		{
			return [];
		}

		// Prepare buffer for reading collision data
		var _scratchBuffer = bbmod_get_scratch_buffer(
			buffer_sizeof(buffer_f64) * 4  // body1 ID + body2 ID + contact count + total impulse
		);

		// Build array of collision info
		var _collisions = array_create(_count);
		for (var i = 0; i < _count; i++)
		{
			// Reset buffer position for each read
			buffer_seek(_scratchBuffer, buffer_seek_start, 0);

			// Get collision info at index i
			BBMOD_PhysicsWorld_GetCollisionInfo(__id, i, buffer_get_address(_scratchBuffer));

			// Read collision data
			var _collision = new BBMOD_CollisionInfo();
			_collision.Body1Id = buffer_read(_scratchBuffer, buffer_f64);
			_collision.Body2Id = buffer_read(_scratchBuffer, buffer_f64);
			_collision.ContactCount = buffer_read(_scratchBuffer, buffer_f64);
			_collision.TotalImpulse = buffer_read(_scratchBuffer, buffer_f64);

			_collisions[i] = _collision;
		}

		return _collisions;
	};

	/// @func draw_debug()
	///
	/// @desc Draws the debug information for the physics world.
	///
	/// @return {Struct.BBMOD_PhysicsWorld} Returns `self`.
	static draw_debug = function ()
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsWorld_DrawDebug(__id);
		var _size = BBMOD_PhysicsWorld_GetDebugDrawSize(__id);
		if (_size > 0)
		{
			var __scratchBuffer = bbmod_get_scratch_buffer(_size);
			BBMOD_PhysicsWorld_GetDebugDrawToBuffer(__id, buffer_get_address(__scratchBuffer));
			buffer_set_used_size(__scratchBuffer, _size);
			var _vbuffer = vertex_create_buffer_from_buffer(__id, BBMOD_VFORMAT_DEBUG.Raw);
			vertex_freeze(_vbuffer);
			shader_set(BBMOD_ShDebug);
			gpu_push_state();
			//gpu_set_zwriteenable(true);
			//gpu_set_ztestenable(true);
			vertex_submit(_vbuffer, pr_linelist, -1);
			gpu_pop_state();
			shader_reset();
			vertex_delete_buffer(_vbuffer);
		}
		return self;
	};

	static destroy = function ()
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsWorld_Destroy(__id);
		__id = -1;
		return undefined;
	};
}
