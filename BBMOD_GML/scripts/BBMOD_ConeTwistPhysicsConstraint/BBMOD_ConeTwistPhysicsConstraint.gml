/// @module Physics

/// @func BBMOD_ConeTwistPhysicsConstraintInfo()
///
/// @desc A struct containing the information needed to create a cone twist
/// physics constraint.
///
/// @see BBMOD_PhysicsConstraint
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_ConeTwistPhysicsConstraintInfo(): BBMOD_PhysicsConstraintInfo() constructor
{
	static PhysicsConstraint_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsConstraintType.ConeTwist;

	// @var {Struct.BBMOD_Matrix} The frame of the first rigid body in the
	/// constraint. Default is the identity matrix.
	Frame1 = new BBMOD_Matrix();

	/// @var {Struct.BBMOD_Matrix} The frame of the second rigid body in the
	/// constraint. Default is the identity matrix.
	Frame2 = new BBMOD_Matrix();

	static to_buffer = function (_buffer)
	{
		PhysicsConstraint_to_buffer(_buffer);
		Frame1.ToBuffer(_buffer, buffer_f64);
		Frame2.ToBuffer(_buffer, buffer_f64);
		return self;
	};
}

/// @func BBMOD_ConeTwistPhysicsConstraint()
///
/// @desc A cone twist physics constraint that constrains two rigid bodies to
/// rotate around a common point while allowing for a limited cone of motion.
/// This constraint is also known as a "spherical" or "ball and socket"
/// constraint.
///
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_ConeTwistPhysicsConstraint(): BBMOD_PhysicsConstraint() constructor
{
	__type = BBMOD_EPhysicsConstraintType.ConeTwist;
	__id = -1;
	__physicsWorld = undefined;
}
