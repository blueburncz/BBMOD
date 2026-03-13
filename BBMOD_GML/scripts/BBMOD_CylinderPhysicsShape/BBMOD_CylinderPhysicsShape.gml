/// @module Physics

/// @func BBMOD_CylinderPhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics
/// cylinder shape.
///
/// @example
/// ```gml
/// // Create a cylinder shape for a barrel (radius 0.3m, height 1.0m)
/// var _cylinderInfo = new BBMOD_CylinderPhysicsShapeInfo();
/// _cylinderInfo.UpAxis = BBMOD_EAxis.Z; // Cylinder stands upright
/// _cylinderInfo.Radius = 0.3;
/// _cylinderInfo.Height = 1.0;
/// var _cylinderShape = physicsEngine.create_physics_shape(_cylinderInfo);
///
/// // Create a dynamic barrel
/// var _rigidBodyInfo = new BBMOD_RigidBodyInfo();
/// _rigidBodyInfo.Shape = _cylinderShape;
/// _rigidBodyInfo.Mass = 20.0;
/// _rigidBodyInfo.Position = new BBMOD_Vec3(0, 0, 2);
/// var _barrel = physicsWorld.create_rigid_body(_rigidBodyInfo);
/// ```
///
/// @see BBMOD_PhysicsShape
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_CylinderPhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsShapeType.Cylinder;

	/// @var {Real} The up axis of the cylinder shape. Default is
	/// {@link BBMOD_EAxis.Z}.
	UpAxis = BBMOD_EAxis.Z;

	/// @var {Real} The radius of the cylinder shape. Default is `0.5`.
	Radius = 0.5;

	/// @var {Real} The height of the cylinder shape. Default is `1.0`.
	Height = 1;

	static to_buffer = function (_buffer)
	{
		PhysicsShapeInfo_to_buffer(_buffer);
		buffer_write(_buffer, buffer_u8, UpAxis);
		buffer_write(_buffer, buffer_f64, Radius);
		buffer_write(_buffer, buffer_f64, Height);
		return self;
	};
}

/// @func BBMOD_CylinderPhysicsShape()
///
/// @desc A cylinder physics shape that represents a cylindrical collision
/// shape.
///
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_CylinderPhysicsShape(): BBMOD_PhysicsShape() constructor
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
