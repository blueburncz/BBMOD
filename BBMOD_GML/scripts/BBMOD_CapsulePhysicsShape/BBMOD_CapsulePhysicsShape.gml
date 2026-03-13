/// @module Physics

/// @func BBMOD_CapsulePhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics
/// capsule shape.
///
/// @example
/// ```gml
/// // Create a capsule shape for a character (radius 0.4m, height 1.8m)
/// var _capsuleInfo = new BBMOD_CapsulePhysicsShapeInfo();
/// _capsuleInfo.UpAxis = BBMOD_EAxis.Z; // Capsule stands upright
/// _capsuleInfo.Radius = 0.4;
/// _capsuleInfo.Height = 1.8;
/// var _capsuleShape = physicsEngine.create_physics_shape(_capsuleInfo);
///
/// // Create a character controller rigid body
/// var _rigidBodyInfo = new BBMOD_RigidBodyInfo();
/// _rigidBodyInfo.Shape = _capsuleShape;
/// _rigidBodyInfo.Mass = 75.0; // 75kg character
/// _rigidBodyInfo.Position = new BBMOD_Vec3(0, 0, 1);
/// var _character = physicsWorld.create_rigid_body(_rigidBodyInfo);
/// _character.set_angular_factor(new BBMOD_Vec3(0, 0, 0)); // Prevent rotation
/// ```
///
/// @see BBMOD_PhysicsShape
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_CapsulePhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsShapeType.Capsule;

	/// @var {Real} The up axis of the capsule shape. Default is
	/// {@link BBMOD_EAxis.Z}.
	UpAxis = BBMOD_EAxis.Z;

	/// @var {Real} The radius of the capsule shape. Default is `0.5`.
	Radius = 0.5;

	/// @var {Real} The height of the capsule shape. Default is `1.0`.
	Height = 1.0;

	static to_buffer = function (_buffer)
	{
		PhysicsShapeInfo_to_buffer(_buffer);
		buffer_write(_buffer, buffer_u8, UpAxis);
		buffer_write(_buffer, buffer_f64, Radius);
		buffer_write(_buffer, buffer_f64, Height);
		return self;
	};
}

/// @func BBMOD_CapsulePhysicsShape()
///
/// @desc A capsule physics shape that represents a cylindrical collision shape
/// with hemispherical ends.
///
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_CapsulePhysicsShape(): BBMOD_PhysicsShape() constructor
{
	/// @func get_up_axis()
	///
	/// @desc Returns the up axis of this physics shape.
	///
	/// @return {Real} The up axis of this physics shape.
	///
	/// @see BBMOD_EAxis
	static get_up_axis = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_PhysicsEngine_GetPhysicsShapeUpAxis(__id);
	};
}
