/// @module Physics

/// @func BBMOD_SixDOFPhysicsConstraintInfo()
///
/// @desc A struct containing the information needed to create a six degrees of
/// freedom (6DOF) physics constraint.
///
/// @see BBMOD_PhysicsConstraint
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_SixDOFPhysicsConstraintInfo(): BBMOD_PhysicsConstraintInfo() constructor
{
	static PhysicsConstraint_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsConstraintType.SixDOF;

	// @var {Struct.BBMOD_Matrix} The frame of the first rigid body in the
	/// constraint. Default is the identity matrix.
	Frame1 = new BBMOD_Matrix();

	/// @var {Struct.BBMOD_Matrix} The frame of the second rigid body in the
	/// constraint. Default is the identity matrix.
	Frame2 = new BBMOD_Matrix();

	/// @var {Struct.BBMOD_Vec3} The lower linear limit of the constraint.
	/// Default is `(0.0, 0.0, 0.0)`.
	LinearLowerLimit = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The upper linear limit of the constraint.
	/// Default is `(0.0, 0.0, 0.0)`.
	LinearUpperLimit = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The lower angular limit of the constraint.
	/// Default is `(0.0, 0.0, 0.0)`.
	AngularLowerLimit = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The upper angular limit of the constraint.
	/// Default is `(0.0, 0.0, 0.0)`.
	AngularUpperLimit = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} Whether to enable linear spring for each axis
	/// of the constraint. Default is `(false, false, false)`.
	EnableLinearSpring = new BBMOD_Vec3(false);

	/// @var {Struct.BBMOD_Vec3} Whether to enable angular spring for each axis
	/// of the constraint. Default is `(false, false, false)`.
	EnableAngularSpring = new BBMOD_Vec3(false);

	/// @var {Struct.BBMOD_Vec3} The linear stiffness of the constraint.
	/// Default is `(0.0, 0.0, 0.0)`.
	LinearStiffness = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The angular stiffness of the constraint.
	/// Default is `(0.0, 0.0, 0.0)`.
	AngularStiffness = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The linear damping of the constraint. Default
	/// is `(0.0, 0.0, 0.0)`.
	LinearDamping = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The angular damping of the constraint. Default
	/// is `(0.0, 0.0, 0.0)`.
	AngularDamping = new BBMOD_Vec3();

	static to_buffer = function (_buffer)
	{
		bbmod_assert(RigidBody2 != undefined, "RigidBody2 must be defined for a SixDOF physics constraint!");
		PhysicsConstraint_to_buffer(_buffer);
		Frame1.ToBuffer(_buffer, buffer_f64);
		Frame2.ToBuffer(_buffer, buffer_f64);
		LinearLowerLimit.ToBuffer(_buffer, buffer_f64);
		LinearUpperLimit.ToBuffer(_buffer, buffer_f64);
		AngularLowerLimit.ToBuffer(_buffer, buffer_f64);
		AngularUpperLimit.ToBuffer(_buffer, buffer_f64);
		EnableLinearSpring.ToBuffer(_buffer, buffer_bool);
		EnableAngularSpring.ToBuffer(_buffer, buffer_bool);
		LinearStiffness.ToBuffer(_buffer, buffer_f64);
		AngularStiffness.ToBuffer(_buffer, buffer_f64);
		LinearDamping.ToBuffer(_buffer, buffer_f64);
		AngularDamping.ToBuffer(_buffer, buffer_f64);
		return self;
	};
}

/// @func BBMOD_SixDOFPhysicsConstraint()
///
/// @desc A six degrees of freedom (6DOF) physics constraint that constrains two
/// rigid bodies to move relative to each other with six degrees of freedom.
/// This constraint is also known as a "6DOF" constraint.
///
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_SixDOFPhysicsConstraint(): BBMOD_PhysicsConstraint() constructor
{
	__type = BBMOD_EPhysicsConstraintType.SixDOF;
	__id = -1;
	__physicsWorld = undefined;
}
