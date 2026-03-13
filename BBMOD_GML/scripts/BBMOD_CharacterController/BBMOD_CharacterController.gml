/// @module Physics

/// @func BBMOD_CharacterControllerInfo()
///
/// @desc A struct containing information for creating a kinematic character
/// controller. The character controller provides ground detection, jumping,
/// slope handling, and step climbing for first/third person characters.
///
/// @see BBMOD_PhysicsWorld.create_character_controller
/// @see BBMOD_CharacterController
function BBMOD_CharacterControllerInfo() constructor
{
	/// @var {Real} The radius of the character's capsule shape. This
	/// determines the character's width.
	Radius = 0.5;

	/// @var {Real} The height of the character's capsule shape (not
	/// including the hemispherical ends). This is the cylinder portion
	/// of the capsule.
	Height = 1.8;

	/// @var {Real} The maximum height of steps the character can climb.
	/// Steps higher than this will block the character.
	StepHeight = 0.35;

	/// @var {Struct.BBMOD_Vec3} The initial position of the character in
	/// world space.
	Position = new BBMOD_Vec3(0.0, 0.0, 0.0);

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the character controller info into the given buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_CharacterControllerInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_f64, Radius);
		buffer_write(_buffer, buffer_f64, Height);
		buffer_write(_buffer, buffer_f64, StepHeight);
		Position.ToBuffer(_buffer, buffer_f64);
		return self;
	};

	/// @func to_abi()
	///
	/// @desc Converts the character controller info to a format suitable
	/// for passing to the native physics engine. This is used internally
	/// when creating a character controller.
	///
	/// @return {Pointer} The address of the buffer containing the
	/// character controller info.
	static to_abi = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		to_buffer(_scratchBuffer);
		return buffer_get_address(_scratchBuffer);
	};
}

/// @func BBMOD_CharacterController()
///
/// @desc A kinematic character controller for first/third person games.
/// Provides ground detection, jumping, slope handling, and automatic step
/// climbing. Use this instead of a rigid body for player-controlled
/// characters.
///
/// @see BBMOD_PhysicsWorld.create_character_controller
/// @see BBMOD_CharacterControllerInfo
function BBMOD_CharacterController() constructor
{
	__id = -1;
	__physicsWorld = undefined;

	/// @func set_walk_direction(_velocity)
	///
	/// @desc Sets the character's walk direction for this frame. Call
	/// this every frame with the desired movement vector. The controller
	/// will handle collisions, slopes, and steps automatically.
	///
	/// @param {Struct.BBMOD_Vec3} _velocity The desired movement velocity
	/// vector (units per second). The controller will scale this based on
	/// the timestep.
	///
	/// @return {Struct.BBMOD_CharacterController} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // In Step event:
	/// var _inputX = keyboard_check(vk_right) - keyboard_check(vk_left);
	/// var _inputY = keyboard_check(vk_up) - keyboard_check(vk_down);
	/// var _moveVec = new BBMOD_Vec3(_inputX * moveSpeed, _inputY * moveSpeed, 0);
	/// characterController.set_walk_direction(_moveVec);
	/// ```
	static set_walk_direction = function (_velocity)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_velocity.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_CharacterController_SetWalkDirection(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func apply_push_forces(_moveDirection[, _pushStrength[, _pushRadius]])
	///
	/// @desc Automatically applies push forces to nearby dynamic objects
	/// (like crates, barrels, etc.) when the character moves. This makes
	/// the character physically push objects out of the way. Call this
	/// each frame after setting the walk direction.
	///
	/// @param {Struct.BBMOD_Vec3} _moveDirection The direction the
	/// character is moving (same vector used in set_walk_direction).
	/// @param {Real} [_pushStrength] The strength of the push force.
	/// Higher values push objects more forcefully. Defaults to `50.0`.
	/// @param {Real} [_pushRadius] The radius around the character to
	/// detect and push objects. Defaults to the capsule radius + 0.5.
	///
	/// @return {Real} The number of objects that were pushed this frame.
	///
	/// @example
	/// ```gml
	/// // In Step event - automatic crate pushing:
	/// var _inputX = keyboard_check(vk_right) - keyboard_check(vk_left);
	/// var _inputY = keyboard_check(vk_up) - keyboard_check(vk_down);
	/// var _moveVec = new BBMOD_Vec3(_inputX * moveSpeed, _inputY * moveSpeed, 0);
	///
	/// characterController.set_walk_direction(_moveVec);
	/// characterController.apply_push_forces(_moveVec); // Auto-push nearby objects!
	/// ```
	static apply_push_forces = function (_moveDirection, _pushStrength = 50.0, _pushRadius = undefined)
	{
		gml_pragma("forceinline");

		// Default push radius to capsule radius + 0.5
		if (_pushRadius == undefined)
		{
			_pushRadius = get_capsule_radius() + 0.5;
		}

		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_moveDirection.ToBuffer(_scratchBuffer, buffer_f64);
		return BBMOD_CharacterController_ApplyPushForces(__id, buffer_get_address(_scratchBuffer), _pushStrength, _pushRadius);
	};

	/// @func set_velocity_for_time_interval(_velocity, _timeInterval)
	///
	/// @desc Sets the character's velocity for a specific time interval.
	/// This is useful for applying external forces like knockback or
	/// wind.
	///
	/// @param {Struct.BBMOD_Vec3} _velocity The velocity vector to apply.
	/// @param {Real} _timeInterval The time interval in seconds.
	///
	/// @return {Struct.BBMOD_CharacterController} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Apply knockback
	/// var _knockback = new BBMOD_Vec3(10, 0, 5);
	/// characterController.set_velocity_for_time_interval(_knockback, 0.5);
	/// ```
	static set_velocity_for_time_interval = function (_velocity, _timeInterval)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_velocity.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_CharacterController_SetVelocityForTimeInterval(__id, buffer_get_address(_scratchBuffer), _timeInterval);
		return self;
	};

	/// @func is_on_ground()
	///
	/// @desc Checks if the character is currently standing on the ground.
	/// Use this to determine if the character can jump.
	///
	/// @return {Bool} Returns `true` if the character is on the ground,
	/// `false` otherwise.
	///
	/// @example
	/// ```gml
	/// if (keyboard_check_pressed(vk_space) && characterController.is_on_ground())
	/// {
	///     characterController.jump(new BBMOD_Vec3(0, 0, jumpSpeed));
	/// }
	/// ```
	static is_on_ground = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_CharacterController_IsOnGround(__id) > 0.5;
	};

	/// @func jump(_velocity)
	///
	/// @desc Makes the character jump with the specified velocity. The
	/// velocity is typically an upward vector (positive Z). This works
	/// even if the character is not on the ground, but you should check
	/// is_on_ground() first for proper jump behavior.
	///
	/// @param {Struct.BBMOD_Vec3} _velocity The jump velocity vector. For
	/// a simple upward jump, use `new BBMOD_Vec3(0, 0, jumpHeight)`.
	///
	/// @return {Struct.BBMOD_CharacterController} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Simple jump
	/// if (keyboard_check_pressed(vk_space) && characterController.is_on_ground())
	/// {
	///     var _jumpVel = new BBMOD_Vec3(0, 0, 5.0);
	///     characterController.jump(_jumpVel);
	/// }
	/// ```
	static jump = function (_velocity)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_velocity.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_CharacterController_Jump(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func set_fall_speed(_speed)
	///
	/// @desc Sets the maximum falling speed of the character. This
	/// controls terminal velocity.
	///
	/// @param {Real} _speed The maximum fall speed (positive value).
	/// Default is typically 55.0.
	///
	/// @return {Struct.BBMOD_CharacterController} Returns `self`.
	static set_fall_speed = function (_speed)
	{
		gml_pragma("forceinline");
		BBMOD_CharacterController_SetFallSpeed(__id, _speed);
		return self;
	};

	/// @func set_jump_speed(_speed)
	///
	/// @desc Sets the jump speed of the character. This affects the
	/// velocity applied when calling jump() without parameters.
	///
	/// @param {Real} _speed The jump speed. Default is typically 10.0.
	///
	/// @return {Struct.BBMOD_CharacterController} Returns `self`.
	static set_jump_speed = function (_speed)
	{
		gml_pragma("forceinline");
		BBMOD_CharacterController_SetJumpSpeed(__id, _speed);
		return self;
	};

	/// @func set_max_slope(_radians)
	///
	/// @desc Sets the maximum slope angle the character can walk up.
	/// Slopes steeper than this will be treated as walls.
	///
	/// @param {Real} _radians The maximum slope angle in radians. For
	/// example, `degtorad(45)` for a 45-degree maximum slope.
	///
	/// @return {Struct.BBMOD_CharacterController} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Allow walking up slopes up to 45 degrees
	/// characterController.set_max_slope(degtorad(45));
	/// ```
	static set_max_slope = function (_radians)
	{
		gml_pragma("forceinline");
		BBMOD_CharacterController_SetMaxSlope(__id, _radians);
		return self;
	};

	/// @func set_step_height(_height)
	///
	/// @desc Sets the maximum height of steps the character can
	/// automatically climb over. Steps higher than this will block the
	/// character's movement.
	///
	/// @param {Real} _height The step height in world units. Default is
	/// set in BBMOD_CharacterControllerInfo.
	///
	/// @return {Struct.BBMOD_CharacterController} Returns `self`.
	static set_step_height = function (_height)
	{
		gml_pragma("forceinline");
		BBMOD_CharacterController_SetStepHeight(__id, _height);
		return self;
	};

	/// @func set_gravity(_gravity)
	///
	/// @desc Sets the gravity vector for this character. This overrides
	/// the world gravity for this specific character.
	///
	/// @param {Struct.BBMOD_Vec3} _gravity The gravity vector. Typically
	/// negative Z, e.g., `new BBMOD_Vec3(0, 0, -9.81)`.
	///
	/// @return {Struct.BBMOD_CharacterController} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Set custom gravity for low-gravity areas
	/// characterController.set_gravity(new BBMOD_Vec3(0, 0, -3.0));
	/// ```
	static set_gravity = function (_gravity)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_gravity.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_CharacterController_SetGravity(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func get_position()
	///
	/// @desc Gets the current position of the character in world space.
	///
	/// @return {Struct.BBMOD_Vec3} The character's current position.
	///
	/// @example
	/// ```gml
	/// var _pos = characterController.get_position();
	/// x = _pos.X;
	/// y = _pos.Y;
	/// z = _pos.Z;
	/// ```
	static get_position = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		BBMOD_CharacterController_GetPosition(__id, buffer_get_address(_scratchBuffer));
		return new BBMOD_Vec3().FromBuffer(_scratchBuffer, buffer_f64);
	};

	/// @func set_position(_position)
	///
	/// @desc Sets the position of the character in world space. Use this
	/// to teleport the character to a new location.
	///
	/// @param {Struct.BBMOD_Vec3} _position The new position for the
	/// character.
	///
	/// @return {Struct.BBMOD_CharacterController} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Teleport character to spawn point
	/// characterController.set_position(new BBMOD_Vec3(spawnX, spawnY, spawnZ));
	/// ```
	static set_position = function (_position)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_position.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_CharacterController_SetPosition(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func set_use_ghost_sweep_test(_enable)
	///
	/// @desc Enables or disables ghost object sweep testing for more
	/// accurate collision detection. This can improve interaction with
	/// dynamic objects like crates.
	///
	/// @param {Bool} _enable Whether to enable ghost sweep testing.
	///
	/// @return {Struct.BBMOD_CharacterController} Returns `self`.
	static set_use_ghost_sweep_test = function (_enable)
	{
		gml_pragma("forceinline");
		BBMOD_CharacterController_SetUseGhostObjectSweepTest(__id, _enable ? 1.0 : 0.0);
		return self;
	};

	/// @func set_capsule_height(_height)
	///
	/// @desc Changes the height of the character's capsule collision
	/// shape. This is useful for implementing crouching. The capsule
	/// radius remains unchanged.
	///
	/// @param {Real} _height The new height for the capsule (the
	/// cylinder portion, not including the hemispherical caps).
	///
	/// @return {Struct.BBMOD_CharacterController} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Crouch (reduce height to half)
	/// if (keyboard_check(vk_control))
	/// {
	///     characterController.set_capsule_height(0.9); // Half of 1.8
	/// }
	/// else
	/// {
	///     characterController.set_capsule_height(1.8); // Stand up
	/// }
	/// ```
	static set_capsule_height = function (_height)
	{
		gml_pragma("forceinline");
		BBMOD_CharacterController_SetCapsuleHeight(__id, _height);
		return self;
	};

	/// @func get_capsule_height()
	///
	/// @desc Gets the current height of the character's capsule
	/// collision shape.
	///
	/// @return {Real} The capsule height (cylinder portion only).
	static get_capsule_height = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_CharacterController_GetCapsuleHeight(__id);
	};

	/// @func get_capsule_radius()
	///
	/// @desc Gets the radius of the character's capsule collision
	/// shape.
	///
	/// @return {Real} The capsule radius.
	static get_capsule_radius = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_CharacterController_GetCapsuleRadius(__id);
	};

	/// @func destroy()
	///
	/// @desc Destroys the character controller and frees its resources.
	/// The character controller should not be used after calling this.
	///
	/// @return {Undefined}
	static destroy = function ()
	{
		gml_pragma("forceinline");
		BBMOD_CharacterController_Destroy(__id);
		__id = -1;
		return undefined;
	};
}
