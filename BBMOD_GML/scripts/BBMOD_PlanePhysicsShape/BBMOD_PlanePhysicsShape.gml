/// @module Physics

/// @func BBMOD_PlanePhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics
/// plane shape.
///
/// @see BBMOD_PhysicsShape
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_PlanePhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsShapeType.Plane;

	/// @var {Struct.BBMOD_Vec3} The normal vector of the plane. Default is
	/// a vector pointing upwards `(0.0, 0.0, 1.0)`.
	Normal = new BBMOD_Vec3(0.0, 0.0, 1.0);

	/// @var {Real} The distance of the plane from the origin along its normal.
	/// Default is `0.0`.
	Distance = 0.0;

	static to_buffer = function (_buffer)
	{
		PhysicsShapeInfo_to_buffer(_buffer);
		Normal.ToBuffer(_buffer, buffer_f64);
		buffer_write(_buffer, buffer_f64, Distance);
		return self;
	};
}
/// @func BBMOD_PlanePhysicsShape()
///
/// @desc A plane physics shape that represents an infinite plane collision
/// shape.
///
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_PlanePhysicsShape(): BBMOD_PhysicsShape() constructor {}
