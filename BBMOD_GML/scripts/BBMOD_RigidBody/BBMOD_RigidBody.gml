/// @module Physics

/// @func BBMOD_RigidBodyInfo()
///
/// @desc A struct containing the information needed to create a rigid body.
///
/// @see BBMOD_RigidBody
/// @see BBMOD_PhysicsWorld.create_rigid_body
function BBMOD_RigidBodyInfo() constructor
{
	/// @var {Struct.BBMOD_PhysicsShape} The shape of the rigid body.
	PhysicsShape = undefined;

	/// @var {Struct.BBMOD_Matrix} The transform of the rigid body.
	Transform = new BBMOD_Matrix();

	/// @var {Real} The mass of the rigid body. Default is `1.0`.
	Mass = 1.0;

	/// @var {Real} The restitution (bounciness) of the rigid body. Default is
	/// `0.0`.
	Restitution = 0.0;

	/// @var {Real} The friction of the rigid body. Default is `0.5`.
	Friction = 0.5;

	/// @var {Real} Collision group bitfield (which groups this body
	/// belongs to). Default is `1` (group 0). Use powers of 2 for
	/// different groups: 1, 2, 4, 8, 16, etc.
	CollisionGroup = 1;

	/// @var {Real} Collision mask bitfield (which groups this body
	/// collides with). Default is `-1` (collide with all groups).
	CollisionMask = -1;

	/// @var {Bool} If `true`, this body is a trigger (sensor) that
	/// detects collisions but does not physically respond to them.
	/// Useful for checkpoints, damage zones, collectibles, etc.
	/// Default is `false`.
	IsTrigger = false;

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the rigid body info into given buffer.
	///
	/// @param {Id.Buffer} The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_RigidBodyInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_f64, PhysicsShape.__id);
		Transform.ToBuffer(_buffer, buffer_f64);
		buffer_write(_buffer, buffer_f64, Mass);
		buffer_write(_buffer, buffer_f64, Restitution);
		buffer_write(_buffer, buffer_f64, Friction);
		buffer_write(_buffer, buffer_s16, CollisionGroup);
		buffer_write(_buffer, buffer_s16, CollisionMask);
		buffer_write(_buffer, buffer_bool, IsTrigger);
		return self;
	};

	/// @func to_abi()
	///
	/// @desc Converts the rigid body info to a format suitable for passing to
	/// the native physics engine. This is used internally when creating a rigid
	/// body, and is not intended to be called directly by user code.
	///
	/// @return {Pointer} The address of the buffer containing the physics
	/// rigid body info.
	static to_abi = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		to_buffer(_scratchBuffer);
		return buffer_get_address(_scratchBuffer);
	};
}

/// @func BBMOD_RigidBody()
///
/// @desc A struct representing a rigid body in the physics world.
///
/// @see BBMOD_PhysicsWorld.create_rigid_body
function BBMOD_RigidBody() constructor
{
	__id = -1;
	_physicsWorld = undefined;
	__matrix = new BBMOD_Matrix()
	__dualQuat = new BBMOD_DualQuaternion();

	/// @func get_matrix()
	///
	/// @desc Gets the world transform matrix of the rigid body.
	///
	/// @return {Struct.BBMOD_Matrix} The world transform matrix of the rigid body.
	static get_matrix = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 16);
		BBMOD_RigidBody_GetMatrix(__id, buffer_get_address(_scratchBuffer));
		__matrix.FromBuffer(_scratchBuffer, buffer_f64);
		return __matrix;
	};

	/// @func set_matrix(_matrix)
	///
	/// @desc Sets the world transform matrix of the rigid body.
	///
	/// @param {Struct.BBMOD_Matrix} _matrix The new world transform matrix of
	/// the rigid body.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	static set_matrix = function (_matrix)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 16);
		_matrix.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_SetMatrix(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func get_dual_quaternion()
	///
	/// @desc Gets the world transform as dual quaternion of the rigid body.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The world transform as dual
	/// quaternion of the rigid body.
	static get_dual_quaternion = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 8);
		BBMOD_RigidBody_GetDualQuat(__id, buffer_get_address(_scratchBuffer));
		__dualQuat.FromBuffer(_scratchBuffer, buffer_f64);
		return __dualQuat;
	};

	/// @func set_dual_quaternion(_dualQuat)
	///
	/// @desc Sets the world transform as a dual quaternion of the rigid body.
	///
	/// @param {Struct.BBMOD_DualQuaternion} _dualQuat The new world transform
	/// as dual quaternion of the rigid body.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	static set_dual_quaternion = function (_dualQuat)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 8);
		_dualQuat.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_SetDualQuat(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	////////////////////////////////////////////////////////////////////////////////
	//
	// Forces and Impulses
	//

	/// @func apply_force(_force, _relativePosition)
	///
	/// @desc Applies a force to the rigid body at a specific relative position.
	/// This can cause both linear and angular motion.
	///
	/// @param {Struct.BBMOD_Vec3} _force The force vector to apply.
	/// @param {Struct.BBMOD_Vec3} _relativePosition The position relative to
	/// the body's center of mass where the force is applied.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Apply an upward force at the front of the object
	/// rigidBody.apply_force(new BBMOD_Vec3(0, 0, 100), new BBMOD_Vec3(10, 0, 0));
	/// ```
	static apply_force = function (_force, _relativePosition)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 6);
		_force.ToBuffer(_scratchBuffer, buffer_f64);
		_relativePosition.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_ApplyForce(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func apply_central_force(_force)
	///
	/// @desc Applies a force to the rigid body's center of mass. This only
	/// causes linear motion, no rotation.
	///
	/// @param {Struct.BBMOD_Vec3} _force The force vector to apply.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Apply constant upward force (like anti-gravity)
	/// rigidBody.apply_central_force(new BBMOD_Vec3(0, 0, 50));
	/// ```
	static apply_central_force = function (_force)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_force.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_ApplyCentralForce(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func apply_torque(_torque)
	///
	/// @desc Applies a torque (rotational force) to the rigid body. This only
	/// causes angular motion, no linear movement.
	///
	/// @param {Struct.BBMOD_Vec3} _torque The torque vector to apply.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Spin the object around its Z axis
	/// rigidBody.apply_torque(new BBMOD_Vec3(0, 0, 10));
	/// ```
	static apply_torque = function (_torque)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_torque.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_ApplyTorque(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func apply_impulse(_impulse, _relativePosition)
	///
	/// @desc Applies an instantaneous impulse to the rigid body at a specific
	/// relative position. Unlike forces, impulses are applied immediately and
	/// affect velocity directly. Use for instant effects like explosions or hits.
	///
	/// @param {Struct.BBMOD_Vec3} _impulse The impulse vector to apply.
	/// @param {Struct.BBMOD_Vec3} _relativePosition The position relative to
	/// the body's center of mass where the impulse is applied.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Kick the ball upward and forward
	/// ball.apply_impulse(new BBMOD_Vec3(50, 0, 100), new BBMOD_Vec3(0, 0, -5));
	/// ```
	static apply_impulse = function (_impulse, _relativePosition)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 6);
		_impulse.ToBuffer(_scratchBuffer, buffer_f64);
		_relativePosition.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_ApplyImpulse(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func apply_central_impulse(_impulse)
	///
	/// @desc Applies an instantaneous impulse to the rigid body's center of mass.
	/// Use for instant linear velocity changes like jumping or explosions.
	///
	/// @param {Struct.BBMOD_Vec3} _impulse The impulse vector to apply.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Make character jump
	/// player.apply_central_impulse(new BBMOD_Vec3(0, 0, 300));
	/// ```
	static apply_central_impulse = function (_impulse)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_impulse.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_ApplyCentralImpulse(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func apply_torque_impulse(_torque)
	///
	/// @desc Applies an instantaneous rotational impulse to the rigid body.
	/// Use for instant angular velocity changes.
	///
	/// @param {Struct.BBMOD_Vec3} _torque The torque impulse vector to apply.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Instantly spin the object
	/// rigidBody.apply_torque_impulse(new BBMOD_Vec3(0, 0, 50));
	/// ```
	static apply_torque_impulse = function (_torque)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_torque.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_ApplyTorqueImpulse(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func clear_forces()
	///
	/// @desc Clears all accumulated forces on the rigid body. This does not
	/// affect velocity or impulses already applied.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	static clear_forces = function ()
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_ClearForces(__id);
		return self;
	};

	////////////////////////////////////////////////////////////////////////////////
	//
	// Velocity Control
	//

	/// @func get_linear_velocity()
	///
	/// @desc Gets the current linear velocity of the rigid body.
	///
	/// @return {Struct.BBMOD_Vec3} The linear velocity vector.
	static get_linear_velocity = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		BBMOD_RigidBody_GetLinearVelocity(__id, buffer_get_address(_scratchBuffer));
		return new BBMOD_Vec3().FromBuffer(_scratchBuffer, buffer_f64);
	};

	/// @func set_linear_velocity(_velocity)
	///
	/// @desc Sets the linear velocity of the rigid body directly. Automatically
	/// activates the body if it was sleeping.
	///
	/// @param {Struct.BBMOD_Vec3} _velocity The new linear velocity vector.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Set object to move forward at speed 10
	/// rigidBody.set_linear_velocity(new BBMOD_Vec3(10, 0, 0));
	/// ```
	static set_linear_velocity = function (_velocity)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_velocity.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_SetLinearVelocity(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func get_angular_velocity()
	///
	/// @desc Gets the current angular velocity (rotation speed) of the rigid body.
	///
	/// @return {Struct.BBMOD_Vec3} The angular velocity vector (axis * speed).
	static get_angular_velocity = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		BBMOD_RigidBody_GetAngularVelocity(__id, buffer_get_address(_scratchBuffer));
		return new BBMOD_Vec3().FromBuffer(_scratchBuffer, buffer_f64);
	};

	/// @func set_angular_velocity(_velocity)
	///
	/// @desc Sets the angular velocity (rotation speed) of the rigid body directly.
	/// Automatically activates the body if it was sleeping.
	///
	/// @param {Struct.BBMOD_Vec3} _velocity The new angular velocity vector.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Spin around Z axis at 5 radians/second
	/// rigidBody.set_angular_velocity(new BBMOD_Vec3(0, 0, 5));
	/// ```
	static set_angular_velocity = function (_velocity)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_velocity.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_SetAngularVelocity(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	////////////////////////////////////////////////////////////////////////////////
	//
	// Body State Control
	//

	/// @func set_active(_active)
	///
	/// @desc Sets whether the rigid body is active. Active bodies participate
	/// in physics simulation. Inactive bodies are "sleeping" for performance.
	///
	/// @param {Bool} _active Whether the body should be active.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	static set_active = function (_active)
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_SetActive(__id, _active ? 1.0 : 0.0);
		return self;
	};

	/// @func is_active()
	///
	/// @desc Checks whether the rigid body is currently active (not sleeping).
	///
	/// @return {Bool} Returns `true` if the body is active, `false` otherwise.
	static is_active = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_IsActive(__id) > 0.5;
	};

	/// @func set_kinematic(_kinematic)
	///
	/// @desc Sets whether the rigid body is kinematic. Kinematic bodies are
	/// not affected by forces but can be moved by setting their transform or
	/// velocity. Useful for moving platforms, doors, etc.
	///
	/// @param {Bool} _kinematic Whether the body should be kinematic.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	static set_kinematic = function (_kinematic)
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_SetKinematic(__id, _kinematic ? 1.0 : 0.0);
		return self;
	};

	/// @func is_kinematic()
	///
	/// @desc Checks whether the rigid body is kinematic.
	///
	/// @return {Bool} Returns `true` if the body is kinematic, `false` otherwise.
	static is_kinematic = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_IsKinematic(__id) > 0.5;
	};

	/// @func set_gravity(_gravity)
	///
	/// @desc Sets a custom gravity vector for this specific rigid body.
	/// Overrides the world gravity for this body.
	///
	/// @param {Struct.BBMOD_Vec3} _gravity The gravity vector for this body.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Make this object have no gravity
	/// rigidBody.set_gravity(new BBMOD_Vec3(0, 0, 0));
	/// ```
	static set_gravity = function (_gravity)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_gravity.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_SetGravity(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func get_gravity()
	///
	/// @desc Gets the gravity vector for this rigid body.
	///
	/// @return {Struct.BBMOD_Vec3} The gravity vector.
	static get_gravity = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		BBMOD_RigidBody_GetGravity(__id, buffer_get_address(_scratchBuffer));
		return new BBMOD_Vec3().FromBuffer(_scratchBuffer, buffer_f64);
	};

	/// @func get_mass()
	///
	/// @desc Gets the mass of the rigid body. Returns 0 for static bodies.
	///
	/// @return {Real} The mass of the body.
	static get_mass = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_GetMass(__id);
	};

	/// @func set_mass_properties(_mass, _inertia)
	///
	/// @desc Sets the mass and inertia tensor of the rigid body.
	///
	/// @param {Real} _mass The new mass.
	/// @param {Struct.BBMOD_Vec3} _inertia The local inertia tensor.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	static set_mass_properties = function (_mass, _inertia)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_inertia.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_SetMassProps(__id, _mass, buffer_get_address(_scratchBuffer));
		return self;
	};

	////////////////////////////////////////////////////////////////////////////////
	//
	// Damping Control
	//

	/// @func set_damping(_linear, _angular)
	///
	/// @desc Sets the linear and angular damping of the rigid body. Damping
	/// reduces velocity over time. Values between 0 (no damping) and 1 (full damping).
	///
	/// @param {Real} _linear Linear damping (0-1).
	/// @param {Real} _angular Angular damping (0-1).
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	static set_damping = function (_linear, _angular)
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_SetDamping(__id, _linear, _angular);
		return self;
	};

	/// @func get_linear_damping()
	///
	/// @desc Gets the linear damping value.
	///
	/// @return {Real} The linear damping.
	static get_linear_damping = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_GetLinearDamping(__id);
	};

	/// @func get_angular_damping()
	///
	/// @desc Gets the angular damping value.
	///
	/// @return {Real} The angular damping.
	static get_angular_damping = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_GetAngularDamping(__id);
	};

	////////////////////////////////////////////////////////////////////////////////
	//
	// Axis Locking
	//

	/// @func set_linear_factor(_factor)
	///
	/// @desc Sets which axes the rigid body can move along. Use 0 to lock an
	/// axis, 1 to allow movement. Useful for 2.5D games or constraining movement.
	///
	/// @param {Struct.BBMOD_Vec3} _factor Factor for each axis (0 = locked, 1 = free).
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Lock Z movement for 2D game
	/// rigidBody.set_linear_factor(new BBMOD_Vec3(1, 1, 0));
	/// ```
	static set_linear_factor = function (_factor)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_factor.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_SetLinearFactor(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func set_angular_factor(_factor)
	///
	/// @desc Sets which axes the rigid body can rotate around. Use 0 to lock
	/// rotation on an axis, 1 to allow it.
	///
	/// @param {Struct.BBMOD_Vec3} _factor Factor for each axis (0 = locked, 1 = free).
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Only allow rotation around Z axis
	/// rigidBody.set_angular_factor(new BBMOD_Vec3(0, 0, 1));
	/// ```
	static set_angular_factor = function (_factor)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_factor.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_RigidBody_SetAngularFactor(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	////////////////////////////////////////////////////////////////////////////////
	//
	// Collision Filtering
	//

	/// @func set_collision_filter(_group, _mask)
	///
	/// @desc Sets the collision group and mask for this rigid body at
	/// runtime. The group determines which groups this body belongs to,
	/// and the mask determines which groups it can collide with. Use
	/// powers of 2 for groups: 1, 2, 4, 8, 16, etc.
	///
	/// @param {Real} _group Collision group bitfield (which groups
	/// this body belongs to).
	/// @param {Real} _mask Collision mask bitfield (which groups this
	/// body collides with).
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Make this body part of group 2 and only collide with groups 1 and 4
	/// rigidBody.set_collision_filter(2, 1 | 4);
	/// ```
	static set_collision_filter = function (_group, _mask)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(
			buffer_sizeof(buffer_s16) * 2
		);
		buffer_write(_scratchBuffer, buffer_s16, _group);
		buffer_write(_scratchBuffer, buffer_s16, _mask);
		BBMOD_RigidBody_SetCollisionFilter(
			_physicsWorld.__id,
			__id,
			buffer_get_address(_scratchBuffer)
		);
		return self;
	};

	////////////////////////////////////////////////////////////////////////////////
	//
	// Trigger Volumes
	//

	/// @func set_trigger(_isTrigger)
	///
	/// @desc Sets whether this rigid body is a trigger (sensor). Triggers
	/// detect collisions but do not physically respond to them - they won't
	/// push or be pushed by other objects. Use with test_contact() or
	/// overlap_shape() to detect when objects enter/exit trigger zones.
	///
	/// @param {Bool} _isTrigger If `true`, the body becomes a trigger.
	/// If `false`, it becomes a normal physics body.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Make this body a checkpoint trigger
	/// checkpointBody.set_trigger(true);
	///
	/// // Later, check if player entered the checkpoint
	/// if (physicsWorld.test_contact(playerBody, checkpointBody))
	/// {
	///     // Player reached checkpoint!
	/// }
	/// ```
	static set_trigger = function (_isTrigger)
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_SetTrigger(__id, _isTrigger ? 1.0 : 0.0);
		return self;
	};

	/// @func is_trigger()
	///
	/// @desc Checks whether this rigid body is currently a trigger (sensor).
	///
	/// @return {Bool} Returns `true` if the body is a trigger, `false`
	/// otherwise.
	static is_trigger = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_IsTrigger(__id) > 0.5;
	};

	////////////////////////////////////////////////////////////////////////////////
	//
	// User Data / Tags
	//

	/// @func set_user_index(_index)
	///
	/// @desc Sets a user-defined integer index on this rigid body. This is
	/// useful for storing GameMaker instance IDs, object types, or other
	/// game-specific identifiers to associate physics bodies with game
	/// objects.
	///
	/// @param {Real} _index The integer index to store. This can be any
	/// integer value, such as an instance ID or custom tag.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Store the GameMaker instance ID in the physics body
	/// myRigidBody.set_user_index(self.id);
	///
	/// // Later, when handling collisions, retrieve the instance ID
	/// var _collisions = physicsWorld.get_collisions();
	/// for (var i = 0; i < array_length(_collisions); i++)
	/// {
	///     var _bodyId = _collisions[i].Body1Id;
	///     // Look up the body and get its associated instance
	///     var _instanceId = someBody.get_user_index();
	/// }
	/// ```
	static set_user_index = function (_index)
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_SetUserIndex(__id, _index);
		return self;
	};

	/// @func get_user_index()
	///
	/// @desc Gets the user-defined integer index stored on this rigid body.
	/// Returns the value previously set with set_user_index(), or -1 if no
	/// user index has been set.
	///
	/// @return {Real} The user index integer value.
	///
	/// @see BBMOD_RigidBody.set_user_index
	static get_user_index = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_GetUserIndex(__id);
	};

	////////////////////////////////////////////////////////////////////////////////
	//
	// Material Properties
	//

	/// @func set_friction(_friction)
	///
	/// @desc Sets the friction coefficient for this rigid body. Friction
	/// determines how much the body resists sliding across surfaces.
	/// Higher values create more resistance (sticky surfaces), while
	/// lower values make surfaces more slippery (ice).
	///
	/// @param {Real} _friction The friction coefficient (typically 0.0
	/// to 1.0, but higher values are allowed). Default is usually 0.5.
	/// Use 0.0 for completely frictionless (ice), 0.5 for normal
	/// surfaces, and 1.0+ for very sticky surfaces.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Create an icy surface
	/// icePlatform.set_friction(0.05);
	///
	/// // Create a sticky surface
	/// stickyFloor.set_friction(1.5);
	/// ```
	static set_friction = function (_friction)
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_SetFriction(__id, _friction);
		return self;
	};

	/// @func get_friction()
	///
	/// @desc Gets the current friction coefficient for this rigid body.
	///
	/// @return {Real} The friction coefficient.
	static get_friction = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_GetFriction(__id);
	};

	/// @func set_restitution(_restitution)
	///
	/// @desc Sets the restitution (bounciness) for this rigid body.
	/// Restitution determines how much energy is retained after a
	/// collision. A value of 0 means no bounce (perfectly inelastic),
	/// while 1 means perfect bounce (perfectly elastic).
	///
	/// @param {Real} _restitution The restitution coefficient (typically
	/// 0.0 to 1.0, but higher values are allowed). Default is usually 0.0.
	/// Use 0.0 for no bounce, 0.5 for moderate bounce, and 1.0+ for
	/// super bouncy surfaces.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Create a bouncy ball
	/// ball.set_restitution(0.8);
	///
	/// // Create a bounce pad that adds energy
	/// bouncePad.set_restitution(1.5);
	/// ```
	static set_restitution = function (_restitution)
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_SetRestitution(__id, _restitution);
		return self;
	};

	/// @func get_restitution()
	///
	/// @desc Gets the current restitution (bounciness) for this rigid body.
	///
	/// @return {Real} The restitution coefficient.
	static get_restitution = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_GetRestitution(__id);
	};

	/// @func set_rolling_friction(_friction)
	///
	/// @desc Sets the rolling friction for this rigid body. Rolling
	/// friction simulates the resistance when objects roll (like a ball
	/// rolling on a surface). This is separate from regular sliding
	/// friction.
	///
	/// @param {Real} _friction The rolling friction coefficient (typically
	/// 0.0 to 1.0). Higher values make rolling objects slow down faster.
	/// Default is usually 0.0.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Make a ball slow down quickly when rolling
	/// ball.set_rolling_friction(0.3);
	/// ```
	static set_rolling_friction = function (_friction)
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_SetRollingFriction(__id, _friction);
		return self;
	};

	/// @func get_rolling_friction()
	///
	/// @desc Gets the current rolling friction for this rigid body.
	///
	/// @return {Real} The rolling friction coefficient.
	static get_rolling_friction = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_GetRollingFriction(__id);
	};

	/// @func set_spinning_friction(_friction)
	///
	/// @desc Sets the spinning friction for this rigid body. Spinning
	/// friction simulates the resistance when objects spin in place
	/// (like a top spinning on a surface). This is useful for objects
	/// that rotate around a vertical axis.
	///
	/// @param {Real} _friction The spinning friction coefficient (typically
	/// 0.0 to 1.0). Higher values make spinning objects slow down faster.
	/// Default is usually 0.0.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Make a spinning top slow down over time
	/// spinningTop.set_spinning_friction(0.2);
	/// ```
	static set_spinning_friction = function (_friction)
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_SetSpinningFriction(__id, _friction);
		return self;
	};

	/// @func get_spinning_friction()
	///
	/// @desc Gets the current spinning friction for this rigid body.
	///
	/// @return {Real} The spinning friction coefficient.
	static get_spinning_friction = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_GetSpinningFriction(__id);
	};

	////////////////////////////////////////////////////////////////////////////////
	//
	// Continuous Collision Detection (CCD)
	//

	/// @func set_ccd_motion_threshold(_threshold)
	///
	/// @desc Sets the motion threshold for Continuous Collision Detection
	/// (CCD). When this rigid body moves faster than this threshold in a
	/// single frame, CCD is activated to prevent tunneling through thin
	/// objects. This is essential for fast-moving projectiles like bullets.
	///
	/// @param {Real} _threshold The motion threshold in world units. Set to
	/// 0 to disable CCD (default), or a small positive value to enable it.
	/// Typical values are around 0.1 to 1.0 depending on object size.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Enable CCD for a fast-moving bullet
	/// bullet.set_ccd_motion_threshold(0.5);
	/// bullet.set_ccd_swept_sphere_radius(0.1);
	/// ```
	static set_ccd_motion_threshold = function (_threshold)
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_SetCcdMotionThreshold(__id, _threshold);
		return self;
	};

	/// @func get_ccd_motion_threshold()
	///
	/// @desc Gets the current CCD motion threshold for this rigid body.
	///
	/// @return {Real} The CCD motion threshold.
	static get_ccd_motion_threshold = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_GetCcdMotionThreshold(__id);
	};

	/// @func set_ccd_swept_sphere_radius(_radius)
	///
	/// @desc Sets the swept sphere radius for Continuous Collision
	/// Detection (CCD). This should be less than the smallest radius of
	/// the collision shape. The swept sphere is used to detect collisions
	/// between frames for fast-moving objects.
	///
	/// @param {Real} _radius The swept sphere radius in world units. Set to
	/// 0 to disable CCD (default), or a positive value smaller than the
	/// object's smallest dimension.
	///
	/// @return {Struct.BBMOD_RigidBody} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Enable CCD for a small bullet (radius 0.1)
	/// bullet.set_ccd_motion_threshold(0.5);  // Enable when moving > 0.5 units/frame
	/// bullet.set_ccd_swept_sphere_radius(0.05);  // Half the bullet radius
	/// ```
	static set_ccd_swept_sphere_radius = function (_radius)
	{
		gml_pragma("forceinline");
		BBMOD_RigidBody_SetCcdSweptSphereRadius(__id, _radius);
		return self;
	};

	/// @func get_ccd_swept_sphere_radius()
	///
	/// @desc Gets the current CCD swept sphere radius for this rigid body.
	///
	/// @return {Real} The CCD swept sphere radius.
	static get_ccd_swept_sphere_radius = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_RigidBody_GetCcdSweptSphereRadius(__id);
	};
}
