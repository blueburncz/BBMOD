/// @module Physics

function BBMOD_SixDOFPhysicsConstraintInfo(): BBMOD_PhysicsConstraintInfo() constructor
{
	RigidBody1 = undefined;
	RigidBody2 = undefined;
	Frame1 = new BBMOD_Matrix();
	Frame2 = new BBMOD_Matrix();
	LinearLowerLimit = new BBMOD_Vec3();
	LinearUpperLimit = new BBMOD_Vec3();
	AngularLowerLimit = new BBMOD_Vec3();
	AngularUpperLimit = new BBMOD_Vec3();
	EnableLinearSpring = new BBMOD_Vec3(false);
	EnableAngularSpring = new BBMOD_Vec3(false);
	LinearStiffness = new BBMOD_Vec3();
	AngularStiffness = new BBMOD_Vec3();
	LinearDamping = new BBMOD_Vec3();
	AngularDamping = new BBMOD_Vec3();

	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_f64, RigidBody1.__id);
		buffer_write(_buffer, buffer_f64, RigidBody2.__id);
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

function BBMOD_SixDOFPhysicsConstraint(): BBMOD_PhysicsConstraint() constructor
{
}
