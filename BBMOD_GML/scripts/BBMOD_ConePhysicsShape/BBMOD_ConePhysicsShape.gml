/// @module Physics

/// @func BBMOD_ConePhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics
/// cone shape.
///
/// @example
/// ```gml
/// // Create a cone shape for a traffic cone (radius 0.2m, height 0.6m)
/// var _coneInfo = new BBMOD_ConePhysicsShapeInfo();
/// _coneInfo.UpAxis = BBMOD_EAxis.Z; // Cone points upward
/// _coneInfo.Radius = 0.2;
/// _coneInfo.Height = 0.6;
/// var _coneShape = physicsEngine.create_physics_shape(_coneInfo);
///
/// // Create a dynamic traffic cone
/// var _rigidBodyInfo = new BBMOD_RigidBodyInfo();
/// _rigidBodyInfo.Shape = _coneShape;
/// _rigidBodyInfo.Mass = 1.0;
/// _rigidBodyInfo.Position = new BBMOD_Vec3(0, 0, 1);
/// var _trafficCone = physicsWorld.create_rigid_body(_rigidBodyInfo);
/// ```
///
/// @see BBMOD_PhysicsShape
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_ConePhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsShapeType.Cone;

	/// @var {Real} The up axis of the cone shape. Default is
	/// {@link BBMOD_EAxis.Z}.
	UpAxis = BBMOD_EAxis.Z;

	/// @var {Real} The radius of the cone shape. Default is `0.5`.
	Radius = 0.5;

	/// @var {Real} The height of the cone shape. Default is `1.0`.
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

/// @func BBMOD_ConePhysicsShape()
///
/// @desc A cone physics shape that represents a conical collision shape.
///
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_ConePhysicsShape(): BBMOD_PhysicsShape() constructor
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
