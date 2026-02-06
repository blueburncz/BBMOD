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
}
