/// @module Physics

function BBMOD_HingePhysicsConstraintInfo(): BBMOD_PhysicsConstraintInfo() constructor
{
	RigidBody1 = undefined;
	RigidBody2 = undefined;
	Pivot1 = new BBMOD_Vec3();
	Pivot2 = new BBMOD_Vec3();
	Axis1 = new BBMOD_Vec3(1.0, 0.0, 0.0);
	Axis2 = new BBMOD_Vec3(1.0, 0.0, 0.0);

	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_f64, RigidBody1.__id);
		buffer_write(_buffer, buffer_f64, (RigidBody2 != undefined) ? RigidBody2.__id : -1);
		Point1.ToBuffer(_buffer, buffer_f64);
		Point2.ToBuffer(_buffer, buffer_f64);
		Axis1.ToBuffer(_buffer, buffer_f64);
		Axis2.ToBuffer(_buffer, buffer_f64);
		return self;
	};
}

function BBMOD_HingePhysicsConstraint(): BBMOD_PhysicsConstraint() constructor
{
}
