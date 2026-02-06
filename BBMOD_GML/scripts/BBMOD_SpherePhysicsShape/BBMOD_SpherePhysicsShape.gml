/// @module Physics

/// @func BBMOD_SpherePhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics
/// sphere shape.
///
/// @see BBMOD_PhysicsShape
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_SpherePhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsShapeType.Sphere;

	/// @var {Real} The radius of the sphere shape. Default is `0.5`.
	Radius = 0.5;

	static to_buffer = function (_buffer)
	{
		PhysicsShapeInfo_to_buffer(_buffer);
		buffer_write(_buffer, buffer_f64, Radius);
		return self;
	};
}

/// @func BBMOD_SpherePhysicsShape()
///
/// @desc A sphere physics shape that represents a spherical collision
/// shape.
///
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_SpherePhysicsShape(): BBMOD_PhysicsShape() constructor {}
