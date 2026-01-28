/// @module Physics

function BBMOD_RigidBodyInfo() constructor
{
	PhysicsShape = undefined;
	Transform = new BBMOD_Matrix();
	Mass = 1.0;
	Restitution = 0.0;
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
}

function BBMOD_RigidBody() constructor
{
	__id = -1;
	__matrix = new BBMOD_Matrix()
	__dualQuat = new BBMOD_DualQuaternion();

	/// @func get_matrix()
	///
	/// @desc
	///
	/// @return {Struct.BBMOD_Matrix}
	static get_matrix = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 16);
		BBMOD_RigidBody_GetMatrixToBuffer(__id, buffer_get_address(_scratchBuffer));
		__matrix.FromBuffer(_scratchBuffer, buffer_f64);
		return __matrix;
	};

	/// @func get_dual_quaternion()
	///
	/// @desc
	///
	/// @return {Struct.BBMOD_DualQuaternion}
	static get_dual_quaternion = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 8);
		BBMOD_RigidBody_GetDualQuatToBuffer(__id, buffer_get_address(_scratchBuffer));
		__dualQuat.FromBuffer(_scratchBuffer, buffer_f64);
		return __dualQuat;
	};
}
