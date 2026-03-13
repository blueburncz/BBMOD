/// @module Physics

/// @func BBMOD_PhysicsWheelInfo()
///
/// @desc A struct containing the information needed to add a wheel to a physics
/// vehicle.
///
//// @see BBMOD_PhysicsVehicle.add_wheel
function BBMOD_PhysicsWheelInfo() constructor
{
	/// @var {Struct.BBMOD_Vec3} The connection point of the wheel relative to
	/// the vehicle's center of mass.
	ConnectionPoint = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The direction of the wheel suspension. Default
	/// is `(0, 0, -1)`.
	Direction = new BBMOD_Vec3(0, 0, -1);

	/// @var {Struct.BBMOD_Vec3} The axle of the wheel. Default is `(0, -1, 0)`.
	Axle = new BBMOD_Vec3(0, -1, 0);

	/// @var {Real} The rest length of the wheel suspension. Default is `0`.
	SuspensionRestLength = 0;

	/// @var {Real} The radius of the wheel. Default is `0`.
	Radius = 0;

	/// @var {Bool} Whether the wheel is a front wheel. Default is `false`.
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

	/// @func to_abi()
	///
	/// @desc Converts the physics wheel info to a format suitable for passing
	/// to the native physics engine. This is used internally when creating a
	/// wheel, and is not intended to be called directly by user code.
	///
	/// @return {Pointer} The address of the buffer containing the physics wheel
	/// info.
	static to_abi = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		to_buffer(_scratchBuffer);
		return buffer_get_address(_scratchBuffer);
	};
}

/// @func BBMOD_PhysicsWheel()
///
/// @desc A physics wheel that can be added to a physics vehicle.
///
/// @see BBMOD_PhysicsVehicle.add_wheel
function BBMOD_PhysicsWheel() constructor
{
	__wheelIndex = -1;
	__vehicle = undefined;
	__matrix = new BBMOD_Matrix();

	/// @func set_brake(_brake)
	///
	/// @desc Sets the brake force for a specific wheel.
	///
	/// @param {Real} _brake The brake force to apply.
	///
	/// @return {Struct.BBMOD_PhysicsWheel} Returns `self`.
	static set_brake = function (_brake)
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsVehicle_SetBrake(__vehicle.__id, __wheelIndex, _brake);
		return self;
	};

	/// @func set_steering(_steering)
	///
	/// @desc Sets the steering angle for a specific wheel.
	///
	/// @param {Real} _steering The steering angle to apply.
	///
	/// @return {Struct.BBMOD_PhysicsWheel} Returns `self`.
	static set_steering = function (_steering)
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsVehicle_SetSteering(__vehicle.__id, __wheelIndex, _steering);
		return self;
	};

	/// @func apply_engine_force(_force)
	///
	/// @desc Applies engine force to a specific wheel.
	///
	/// @param {Real} _force The force to apply.
	///
	/// @return {Struct.BBMOD_PhysicsWheel} Returns `self`.
	static apply_engine_force = function (_force)
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsVehicle_ApplyEngineForce(__vehicle.__id, __wheelIndex, _force);
		return self
	};

	/// @func get_matrix()
	///
	/// @desc Gets the transformation matrix of a specific wheel.
	///
	/// @return {Struct.BBMOD_Matrix} The transformation matrix of the wheel.
	static get_matrix = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 16);
		BBMOD_PhysicsVehicle_GetWheelTransform(__vehicle.__id, __wheelIndex, buffer_get_address(_scratchBuffer));
		return __matrix.FromBuffer(_scratchBuffer, buffer_f64);
	};
}

/// @func BBMOD_PhysicsVehicleInfo()
///
/// @desc A struct containing the information needed to create a physics vehicle.
///
/// @example
/// ```gml
/// // Create a vehicle chassis
/// var _chassisShape = physicsEngine.create_physics_shape(new BBMOD_BoxPhysicsShapeInfo());
/// var _rigidBodyInfo = new BBMOD_RigidBodyInfo();
/// _rigidBodyInfo.Shape = _chassisShape;
/// _rigidBodyInfo.Mass = 800.0; // 800kg car
/// _rigidBodyInfo.Position = new BBMOD_Vec3(0, 0, 2);
/// var _chassis = physicsWorld.create_rigid_body(_rigidBodyInfo);
///
/// // Create the vehicle
/// var _vehicleInfo = new BBMOD_PhysicsVehicleInfo();
/// _vehicleInfo.RigidBody = _chassis;
/// _vehicleInfo.SuspensionStiffness = 20.0;
/// _vehicleInfo.SuspensionDamping = 2.3;
/// _vehicleInfo.SuspensionCompression = 4.4;
/// var _car = physicsWorld.create_vehicle(_vehicleInfo);
///
/// // See add_wheel() for example of adding wheels
/// ```
///
/// @see BBMOD_PhysicsVehicle
/// @see BBMOD_PhysicsWorld.create_vehicle
function BBMOD_PhysicsVehicleInfo() constructor
{
	/// @var {Real} The suspension stiffness of the vehicle. Default is `5.88`.
	SuspensionStiffness = 5.88;

	/// @var {Real} The suspension compression of the vehicle. Default is `0.83`.
	SuspensionCompression = 0.83;

	/// @var {Real} The suspension damping of the vehicle. Default is `0.88`.
	SuspensionDamping = 0.88;

	/// @var {Real} The maximum suspension travel of the vehicle in centimeters.
	/// Default is `500.0`.
	MaxSuspensionTravelCm = 500.0;

	/// @var {Real} The friction slip of the vehicle. Default is `10.5`.
	FrictionSlip = 10.5;

	/// @var {Real} The maximum suspension force of the vehicle. Default is
	/// `6000.0`.
	MaxSuspensionForce = 6000.0;

	/// @var {Struct.BBMOD_RigidBody} The rigid body associated with the
	/// vehicle.
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

	/// @func to_abi()
	///
	/// @desc Converts the physics vehicle info to a format suitable for passing
	/// to the native physics engine. This is used internally when creating a
	/// vehicle, and is not intended to be called directly by user code.
	///
	/// @return {Pointer} The address of the buffer containing the physics
	/// vehicle info.
	static to_abi = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		to_buffer(_scratchBuffer);
		return buffer_get_address(_scratchBuffer);
	};
}

/// @func BBMOD_PhysicsVehicle()
///
/// @desc A physics vehicle that can be added to a physics world.
///
/// @see BBMOD_PhysicsWorld.create_vehicle
function BBMOD_PhysicsVehicle() constructor
{
	__id = -1;
	__physicsWorld = undefined;

	/// @func add_wheel(_info)
	///
	/// @desc Adds a wheel to the physics vehicle.
	///
	/// @param {Struct.BBMOD_PhysicsWheelInfo} _info The information of the
	/// wheel to add.
	///
	/// @return {Struct.BBMOD_PhysicsWheel} The added wheel.
	///
	/// @example
	/// ```gml
	/// // Add four wheels to a vehicle
	/// var _wheelInfo = new BBMOD_PhysicsWheelInfo();
	/// _wheelInfo.Radius = 0.4;
	/// _wheelInfo.SuspensionRestLength = 0.6;
	/// _wheelInfo.Direction = new BBMOD_Vec3(0, 0, -1);
	/// _wheelInfo.Axle = new BBMOD_Vec3(0, -1, 0);
	///
	/// // Front-left wheel
	/// _wheelInfo.ConnectionPoint = new BBMOD_Vec3(-0.9, 1.2, 0.5);
	/// _wheelInfo.IsFrontWheel = true;
	/// var _wheelFL = _car.add_wheel(_wheelInfo);
	///
	/// // Front-right wheel
	/// _wheelInfo.ConnectionPoint = new BBMOD_Vec3(0.9, 1.2, 0.5);
	/// _wheelInfo.IsFrontWheel = true;
	/// var _wheelFR = _car.add_wheel(_wheelInfo);
	///
	/// // Rear-left wheel
	/// _wheelInfo.ConnectionPoint = new BBMOD_Vec3(-0.9, -1.2, 0.5);
	/// _wheelInfo.IsFrontWheel = false;
	/// var _wheelRL = _car.add_wheel(_wheelInfo);
	///
	/// // Rear-right wheel
	/// _wheelInfo.ConnectionPoint = new BBMOD_Vec3(0.9, -1.2, 0.5);
	/// _wheelInfo.IsFrontWheel = false;
	/// var _wheelRR = _car.add_wheel(_wheelInfo);
	///
	/// // Apply controls to the wheels
	/// _wheelFL.set_steering(0.3);
	/// _wheelFR.set_steering(0.3);
	/// _wheelRL.apply_engine_force(1000.0);
	/// _wheelRR.apply_engine_force(1000.0);
	/// ```
	static add_wheel = function (_info)
	{
		gml_pragma("forceinline");
		var _wheel = new BBMOD_PhysicsWheel();
		_wheel.__wheelIndex = BBMOD_PhysicsVehicle_AddWheel(__id, _info.to_abi());
		_wheel.__vehicle = self;
		return _wheel;
	};

	/// @func get_num_wheels()
	///
	/// @desc Gets the number of wheels currently added to the vehicle.
	///
	/// @return {Real} The number of wheels currently added to the vehicle.
	static get_num_wheels = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_PhysicsVehicle_GetNumWheels(__id);
	};

	/// @func get_wheel(_index)
	///
	/// @desc Gets a specific wheel of the vehicle.
	///
	/// @param {Real} _index The index of the wheel to get.
	///
	/// @return {Struct.BBMOD_PhysicsWheel} The wheel at the specified index.
	static get_wheel = function (_index)
	{
		gml_pragma("forceinline");
		var _wheel = new BBMOD_PhysicsWheel();
		_wheel.__wheelIndex = _index;
		_wheel.__vehicle = self;
		return _wheel;
	};
}
