/// @module Physics

function BBMOD_PointPhysicsConstraintInfo(): BBMOD_PhysicsConstraintInfo() constructor
{
	RigidBody1 = undefined;
	RigidBody2 = undefined;
	Pivot1 = new BBMOD_Vec3();
	Pivot2 = new BBMOD_Vec3();

	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_f64, RigidBody1.__id);
		buffer_write(_buffer, buffer_f64, (RigidBody2 != undefined) ? RigidBody2.__id : -1);
		Point1.ToBuffer(_buffer, buffer_f64);
		Point2.ToBuffer(_buffer, buffer_f64);
		return self;
	};
}

function BBMOD_PointPhysicsConstraint(): BBMOD_PhysicsConstraint() constructor {}
