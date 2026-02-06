/// @module Physics

/// @func BBMOD_PointPhysicsConstraintInfo()
///
/// @desc A struct containing the information needed to create a point physics
/// constraint.
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
