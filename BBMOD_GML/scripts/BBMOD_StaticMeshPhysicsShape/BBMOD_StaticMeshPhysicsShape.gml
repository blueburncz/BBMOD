/// @module Physics

/// @func BBMOD_StaticMeshPhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics static
/// mesh shape.
///
/// @see BBMOD_PhysicsShape
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_StaticMeshPhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsShapeType.StaticMesh;

	/// @var {Id.Buffer} A buffer containing the vertex data of the static mesh
	/// shape. The buffer should contain an array of 3D vectors, where each
	/// vector represents a vertex of the static mesh.
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

/// @func BBMOD_StaticMeshPhysicsShape()
///
/// @desc A static mesh physics shape that represents a collision shape defined
/// by a set of vertices.
///
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_StaticMeshPhysicsShape(): BBMOD_PhysicsShape() constructor {}
