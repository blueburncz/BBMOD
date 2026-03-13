/// @module Physics

/// @func BBMOD_PointPhysicsConstraintInfo()
///
/// @desc A struct containing the information needed to create a point physics
/// constraint.
///
/// @example
/// ```gml
/// // Create a chain of connected objects
/// var _link1Info = new BBMOD_RigidBodyInfo();
/// _link1Info.Shape = boxShape;
/// _link1Info.Mass = 5.0;
/// _link1Info.Position = new BBMOD_Vec3(0, 0, 5);
/// var _link1 = physicsWorld.create_rigid_body(_link1Info);
///
/// var _link2Info = new BBMOD_RigidBodyInfo();
/// _link2Info.Shape = boxShape;
/// _link2Info.Mass = 5.0;
/// _link2Info.Position = new BBMOD_Vec3(0, 0, 3);
/// var _link2 = physicsWorld.create_rigid_body(_link2Info);
///
/// // Connect the links with a point-to-point constraint
/// var _pointInfo = new BBMOD_PointPhysicsConstraintInfo();
/// _pointInfo.RigidBody1 = _link1;
/// _pointInfo.RigidBody2 = _link2;
/// _pointInfo.Pivot1 = new BBMOD_Vec3(0, 0, -1); // Bottom of link1
/// _pointInfo.Pivot2 = new BBMOD_Vec3(0, 0, 1);  // Top of link2
/// var _chain = physicsWorld.create_constraint(_pointInfo);
/// ```
///
/// @see BBMOD_PhysicsConstraint
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_PointPhysicsConstraintInfo(): BBMOD_PhysicsConstraintInfo() constructor
{
	static PhysicsConstraint_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsConstraintType.Point;

	/// @var {Struct.BBMOD_Vec3} The pivot point of the first rigid body in
	/// the constraint. Default is `(0.0, 0.0, 0.0)`.
	Pivot1 = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The pivot point of the second rigid body in
	/// the constraint. Default is `(0.0, 0.0, 0.0)`.
	Pivot2 = new BBMOD_Vec3();

	static to_buffer = function (_buffer)
	{
		PhysicsConstraint_to_buffer(_buffer);
		Pivot1.ToBuffer(_buffer, buffer_f64);
		Pivot2.ToBuffer(_buffer, buffer_f64);
		return self;
	};
}

/// @func BBMOD_PointPhysicsConstraint()
///
/// @desc A point physics constraint that constrains two rigid bodies to a
/// single point in space. This constraint is also known as a "ball and socket"
/// constraint.
///
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_PointPhysicsConstraint(): BBMOD_PhysicsConstraint() constructor
{
	__type = BBMOD_EPhysicsConstraintType.Point;
	__id = -1;
	__physicsWorld = undefined;
}
