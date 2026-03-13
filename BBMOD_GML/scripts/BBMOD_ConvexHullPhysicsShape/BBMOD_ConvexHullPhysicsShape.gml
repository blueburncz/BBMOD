/// @module Physics

/// @func BBMOD_ConvexHullPhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics convex
/// hull shape.
///
/// @example
/// ```gml
/// // Create a convex hull from a model's vertex data
/// var _model = new BBMOD_Model("rock.bbmod");
/// var _mesh = _model.Meshes[0];
///
/// // Extract vertex positions from the mesh
/// var _vertexBuffer = buffer_create_from_vertex_buffer(_mesh.VertexBuffer, buffer_fixed, 1);
/// var _vertexFormat = _mesh.VertexFormat;
/// var _vertexSize = _vertexFormat.get_byte_size();
///
/// // Create convex hull shape
/// var _convexInfo = new BBMOD_ConvexHullPhysicsShapeInfo();
/// _convexInfo.Buffer = _vertexBuffer;
/// _convexInfo.VertexCount = buffer_get_size(_vertexBuffer) / _vertexSize;
/// _convexInfo.VertexStride = _vertexSize;
/// var _convexShape = physicsEngine.create_physics_shape(_convexInfo);
///
/// // Use the convex hull for a dynamic object
/// var _rigidBodyInfo = new BBMOD_RigidBodyInfo();
/// _rigidBodyInfo.Shape = _convexShape;
/// _rigidBodyInfo.Mass = 5.0;
/// var _rock = physicsWorld.create_rigid_body(_rigidBodyInfo);
/// ```
///
/// @see BBMOD_PhysicsShape
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_ConvexHullPhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsShapeType.ConvexHull;

	/// @var {Id.Buffer} A buffer containing the vertex data of the convex hull
	/// shape. The buffer should contain an array of 3D vectors, where each
	/// vector represents a vertex of the convex hull.
	Buffer = -1;

	/// @var {Int32} The number of vertices in the buffer. Default is `0`.
	VertexCount = 0;

	/// @var {Int32} The stride of the vertex data in the buffer, in bytes.
	/// This should be set to the size of a single vertex in the buffer. Default
	/// is `0`.
	VertexStride = 0;

	static to_buffer = function (_buffer)
	{
		PhysicsShapeInfo_to_buffer(_buffer);
		buffer_write(_buffer, buffer_u32, VertexCount);
		buffer_write(_buffer, buffer_u32, VertexStride);
		if (Buffer != -1)
		{
			buffer_copy(Buffer, 0, _buffer, buffer_tell(_buffer), VertexCount * VertexStride);
		}
		return self;
	};
}

/// @func BBMOD_ConvexHullPhysicsShape()
///
/// @desc A convex hull physics shape that represents a collision shape defined
/// by a set of vertices.
///
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_ConvexHullPhysicsShape(): BBMOD_PhysicsShape() constructor {}
