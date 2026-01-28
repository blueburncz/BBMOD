/// @module Physics

function BBMOD_SliderPhysicsConstraintInfo(): BBMOD_PhysicsConstraintInfo() constructor
{
	RigidBody1 = undefined;
	RigidBody2 = undefined;
	Frame1 = new BBMOD_Matrix();
	Frame2 = new BBMOD_Matrix();

	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_f64, RigidBody1.__id);
		buffer_write(_buffer, buffer_f64, (RigidBody2 != undefined) ? RigidBody2.__id : -1);
		Frame1.ToBuffer(_buffer, buffer_f64);
		Frame2.ToBuffer(_buffer, buffer_f64);
		return self;
	};
}

function BBMOD_SliderPhysicsConstraint(): BBMOD_PhysicsConstraint() constructor
{
}
