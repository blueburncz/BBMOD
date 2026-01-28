/// @module Physics

function BBMOD_PhysicsVehicleInfo() constructor
{
	SuspensionStiffness = 5.88;
	SuspensionCompression = 0.83;
	SuspensionDamping = 0.88;
	MaxSuspensionTravelCm = 500.0;
	FrictionSlip = 10.5;
	MaxSuspensionForce = 6000.0;
	RigidBody = undefined;

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the vehicle info into given buffer.
	///
	/// @param {Id.Buffer} The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_PhysicsVehicleInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_f64, SuspensionStiffness);
		buffer_write(_buffer, buffer_f64, SuspensionCompression);
		buffer_write(_buffer, buffer_f64, SuspensionDamping);
		buffer_write(_buffer, buffer_f64, MaxSuspensionTravelCm);
		buffer_write(_buffer, buffer_f64, FrictionSlip);
		buffer_write(_buffer, buffer_f64, MaxSuspensionForce);
		buffer_write(_buffer, buffer_f64, RigidBody.__id);
		return self;
	};
}

function BBMOD_PhysicsWheelInfo() constructor
{
	ConnectionPoint = new BBMOD_Vec3();
	Direction = new BBMOD_Vec3(0, 0, -1);
	Axle = new BBMOD_Vec3(0, -1, 0);
	SuspensionRestLength = 0;
	Radius = 0;
	IsFrontWheel = false;

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the wheel info into given buffer.
	///
	/// @param {Id.Buffer} The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_PhysicsWheelInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		ConnectionPoint.ToBuffer(_buffer, buffer_f64);
		Direction.ToBuffer(_buffer, buffer_f64);
		Axle.ToBuffer(_buffer, buffer_f64);
		buffer_write(_buffer, buffer_f64, SuspensionRestLength);
		buffer_write(_buffer, buffer_f64, Radius);
		buffer_write(_buffer, buffer_bool, IsFrontWheel);
		return self;
	};
}

function BBMOD_PhysicsVehicle() constructor
{
	__id = -1;

	/// @func add_wheel(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_PhysicsWheelInfo} _info
	///
	/// @return {Real}
	static add_wheel = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		return BBMOD_PhysicsVehicle_AddWheel(__id, buffer_get_address(_scratchBuffer));
	};

	/// @func set_brake(_wheelIndex, _brake)
	///
	/// @desc
	///
	/// @param {Real} _wheelIndex
	/// @param {Real} _brake
	static set_brake = function (_wheelIndex, _brake)
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsVehicle_SetBrake(__id, _wheelIndex, _brake);
	};

	/// @func set_steering(_wheelIndex, _steering)
	///
	/// @desc
	///
	/// @param {Real} _wheelIndex
	/// @param {Real} _steering
	static set_steering = function (_wheelIndex, _steering)
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsVehicle_SetSteering(__id, _wheelIndex, _steering);
	};

	/// @func apply_engine_force(_wheelIndex, _force)
	///
	/// @desc
	///
	/// @param {Real} _wheelIndex
	/// @param {Real} _force
	static apply_engine_force = function (_wheelIndex, _force)
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsVehicle_ApplyEngineForce(__id, _wheelIndex, _force);
	};

	/// @func get_wheel_transform(_wheelIndex)
	///
	/// @desc
	///
	/// @param {Real} _wheelIndex
	///
	/// @return {Array<Real>}
	static get_wheel_transform = function (_wheelIndex)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 16);
		BBMOD_PhysicsVehicle_GetWheelTransform(__id, _wheelIndex, buffer_get_address(_scratchBuffer));
		var _transform = array_create(16);
		for (var i = 0; i < 16; ++i)
		{
			_transform[@ i] = buffer_read(_scratchBuffer, buffer_f64);
		}
		return _transform;
	};
}
