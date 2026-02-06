/// @module Physics

/// @func BBMOD_HingePhysicsConstraintInfo()
///
/// @desc A struct containing the information needed to create a hinge physics
/// constraint.
///
/// @see BBMOD_PhysicsConstraint
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_HingePhysicsConstraintInfo(): BBMOD_PhysicsConstraintInfo() constructor
{
	static PhysicsConstraint_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsConstraintType.Hinge;

	/// @var {Struct.BBMOD_Vec3} The pivot point of the first rigid body in
	/// the constraint. Default is `(0.0, 0.0, 0.0)`.
	Pivot1 = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The pivot point of the second rigid body in
	/// the constraint. Default is `(0.0, 0.0, 0.0)`.
	Pivot2 = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The first axis of the constraint. Default
	/// is `(1.0, 0.0, 0.0)`.
	Axis1 = new BBMOD_Vec3(1.0, 0.0, 0.0);

	/// @var {Struct.BBMOD_Vec3} The second axis of the constraint.
	/// Default is `(1.0, 0.0, 0.0)`.
	Axis2 = new BBMOD_Vec3(1.0, 0.0, 0.0);

	static to_buffer = function (_buffer)
	{
		PhysicsConstraint_to_buffer(_buffer);
		Pivot1.ToBuffer(_buffer, buffer_f64);
		Pivot2.ToBuffer(_buffer, buffer_f64);
		Axis1.ToBuffer(_buffer, buffer_f64);
		Axis2.ToBuffer(_buffer, buffer_f64);
		return self;
	};
}

/// @func BBMOD_HingePhysicsConstraint()
///
/// @desc A hinge physics constraint that constrains two rigid bodies to rotate
/// around a single axis. This constraint is also known as a "revolute"
/// constraint.
///
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_HingePhysicsConstraint(): BBMOD_PhysicsConstraint() constructor
{
	__type = BBMOD_EPhysicsConstraintType.Hinge;
	__id = -1;
	__physicsWorld = undefined;
}
