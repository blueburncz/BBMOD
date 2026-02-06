/// @module Physics

/// @func BBMOD_SliderPhysicsConstraintInfo()
///
/// @desc A struct containing the information needed to create a slider physics
/// constraint.
///
/// @see BBMOD_PhysicsConstraint
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_SliderPhysicsConstraintInfo(): BBMOD_PhysicsConstraintInfo() constructor
{
	static PhysicsConstraint_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsConstraintType.Slider;

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

/// @func BBMOD_SliderPhysicsConstraint()
///
/// @desc A slider physics constraint that constrains two rigid bodies to slide
/// along a single axis. This constraint is also known as a "prismatic"
/// constraint.
///
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_SliderPhysicsConstraint(): BBMOD_PhysicsConstraint() constructor
{
	__type = BBMOD_EPhysicsConstraintType.Slider;
	__id = -1;
	__physicsWorld = undefined;
}
