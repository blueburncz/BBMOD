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

	/// @func enable_motor(_enable)
	///
	/// @desc Enables or disables the hinge motor. When enabled, the motor
	/// will attempt to rotate the hinge toward the target angle with the
	/// specified force.
	///
	/// @param {Bool} _enable Whether to enable the motor.
	///
	/// @return {Struct.BBMOD_HingePhysicsConstraint} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Create a powered door hinge
	/// doorHinge.enable_motor(true);
	/// doorHinge.set_max_motor_impulse(10.0);
	/// doorHinge.set_motor_target(degtorad(90), delta_time / 1000000); // Open door
	/// ```
	static enable_motor = function (_enable)
	{
		gml_pragma("forceinline");
		BBMOD_HingeConstraint_EnableMotor(__id, _enable ? 1.0 : 0.0);
		return self;
	};

	/// @func set_motor_target(_targetAngle, _dt)
	///
	/// @desc Sets the target angle for the hinge motor. The motor will
	/// attempt to rotate the hinge to this angle.
	///
	/// @param {Real} _targetAngle The target angle in radians.
	/// @param {Real} _dt The time step in seconds. Use `delta_time / 1000000`.
	///
	/// @return {Struct.BBMOD_HingePhysicsConstraint} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Rotate door to 90 degrees open
	/// doorHinge.set_motor_target(degtorad(90), delta_time / 1000000);
	/// ```
	static set_motor_target = function (_targetAngle, _dt)
	{
		gml_pragma("forceinline");
		BBMOD_HingeConstraint_SetMotorTarget(__id, _targetAngle, _dt);
		return self;
	};

	/// @func set_max_motor_impulse(_maxImpulse)
	///
	/// @desc Sets the maximum impulse (force) the motor can apply to reach
	/// the target angle. Higher values result in stronger, faster rotation.
	///
	/// @param {Real} _maxImpulse The maximum motor impulse.
	///
	/// @return {Struct.BBMOD_HingePhysicsConstraint} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Weak motor for slow, smooth rotation
	/// doorHinge.set_max_motor_impulse(5.0);
	///
	/// // Strong motor for fast, powerful rotation
	/// engineHinge.set_max_motor_impulse(100.0);
	/// ```
	static set_max_motor_impulse = function (_maxImpulse)
	{
		gml_pragma("forceinline");
		BBMOD_HingeConstraint_SetMaxMotorImpulse(__id, _maxImpulse);
		return self;
	};

	/// @func get_hinge_angle()
	///
	/// @desc Gets the current angle of the hinge in radians.
	///
	/// @return {Real} The current hinge angle in radians.
	///
	/// @example
	/// ```gml
	/// var _angle = doorHinge.get_hinge_angle();
	/// var _degrees = radtodeg(_angle);
	/// show_debug_message($"Door is open {_degrees} degrees");
	/// ```
	static get_hinge_angle = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_HingeConstraint_GetHingeAngle(__id);
	};
}
