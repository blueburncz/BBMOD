/// @module Physics

/// @func BBMOD_SpherePhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics
/// sphere shape.
///
/// @example
/// ```gml
/// // Create a sphere shape for a ball (0.5m radius)
/// var _sphereInfo = new BBMOD_SpherePhysicsShapeInfo();
/// _sphereInfo.Radius = 0.5;
/// var _sphereShape = physicsEngine.create_physics_shape(_sphereInfo);
///
/// // Create a bouncy ball with high restitution
/// var _rigidBodyInfo = new BBMOD_RigidBodyInfo();
/// _rigidBodyInfo.Shape = _sphereShape;
/// _rigidBodyInfo.Mass = 1.0;
/// _rigidBodyInfo.Position = new BBMOD_Vec3(0, 0, 10);
/// var _ball = physicsWorld.create_rigid_body(_rigidBodyInfo);
/// _ball.set_restitution(0.9); // Very bouncy
/// ```
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
