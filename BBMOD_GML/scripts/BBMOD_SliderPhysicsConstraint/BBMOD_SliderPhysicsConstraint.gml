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

	/// @func set_powered_lin_motor(_enable)
	///
	/// @desc Enables or disables the linear motor for this slider. When
	/// enabled, the motor will attempt to slide the bodies along the
	/// constraint axis toward the target velocity.
	///
	/// @param {Bool} _enable Whether to enable the linear motor.
	///
	/// @return {Struct.BBMOD_SliderPhysicsConstraint} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Create a powered elevator platform
	/// elevatorSlider.set_powered_lin_motor(true);
	/// elevatorSlider.set_target_lin_motor_velocity(2.0); // Move up at 2 units/sec
	/// elevatorSlider.set_max_lin_motor_force(1000.0);
	/// ```
	static set_powered_lin_motor = function (_enable)
	{
		gml_pragma("forceinline");
		BBMOD_SliderConstraint_SetPoweredLinMotor(__id, _enable ? 1.0 : 0.0);
		return self;
	};

	/// @func set_target_lin_motor_velocity(_velocity)
	///
	/// @desc Sets the target linear velocity for the slider motor. The
	/// motor will attempt to move the slider at this speed along its axis.
	///
	/// @param {Real} _velocity The target linear velocity in units per second.
	/// Positive values move in one direction, negative in the other.
	///
	/// @return {Struct.BBMOD_SliderPhysicsConstraint} Returns `self`.
	static set_target_lin_motor_velocity = function (_velocity)
	{
		gml_pragma("forceinline");
		BBMOD_SliderConstraint_SetTargetLinMotorVelocity(__id, _velocity);
		return self;
	};

	/// @func set_max_lin_motor_force(_force)
	///
	/// @desc Sets the maximum force the linear motor can apply. Higher
	/// values result in stronger, more responsive movement.
	///
	/// @param {Real} _force The maximum motor force.
	///
	/// @return {Struct.BBMOD_SliderPhysicsConstraint} Returns `self`.
	static set_max_lin_motor_force = function (_force)
	{
		gml_pragma("forceinline");
		BBMOD_SliderConstraint_SetMaxLinMotorForce(__id, _force);
		return self;
	};

	/// @func set_powered_ang_motor(_enable)
	///
	/// @desc Enables or disables the angular motor for this slider. When
	/// enabled, the motor will attempt to rotate the bodies around the
	/// constraint axis.
	///
	/// @param {Bool} _enable Whether to enable the angular motor.
	///
	/// @return {Struct.BBMOD_SliderPhysicsConstraint} Returns `self`.
	static set_powered_ang_motor = function (_enable)
	{
		gml_pragma("forceinline");
		BBMOD_SliderConstraint_SetPoweredAngMotor(__id, _enable ? 1.0 : 0.0);
		return self;
	};

	/// @func set_target_ang_motor_velocity(_velocity)
	///
	/// @desc Sets the target angular velocity for the slider motor. The
	/// motor will attempt to rotate at this speed around the slider axis.
	///
	/// @param {Real} _velocity The target angular velocity in radians per second.
	///
	/// @return {Struct.BBMOD_SliderPhysicsConstraint} Returns `self`.
	static set_target_ang_motor_velocity = function (_velocity)
	{
		gml_pragma("forceinline");
		BBMOD_SliderConstraint_SetTargetAngMotorVelocity(__id, _velocity);
		return self;
	};

	/// @func set_max_ang_motor_force(_force)
	///
	/// @desc Sets the maximum force the angular motor can apply. Higher
	/// values result in stronger, more responsive rotation.
	///
	/// @param {Real} _force The maximum motor force.
	///
	/// @return {Struct.BBMOD_SliderPhysicsConstraint} Returns `self`.
	static set_max_ang_motor_force = function (_force)
	{
		gml_pragma("forceinline");
		BBMOD_SliderConstraint_SetMaxAngMotorForce(__id, _force);
		return self;
	};

	/// @func get_linear_pos()
	///
	/// @desc Gets the current linear position of the slider along its axis.
	///
	/// @return {Real} The current linear position.
	static get_linear_pos = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_SliderConstraint_GetLinearPos(__id);
	};

	/// @func get_angular_pos()
	///
	/// @desc Gets the current angular position of the slider around its axis.
	///
	/// @return {Real} The current angular position in radians.
	static get_angular_pos = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_SliderConstraint_GetAngularPos(__id);
	};
}
