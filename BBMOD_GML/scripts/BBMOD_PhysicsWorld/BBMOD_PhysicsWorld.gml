/// @module Physics

// TODO: Replace Bullet-specific debug modes with mapping to BBMOD debug modes.

/// @enum Enumeration representing debug draw modes for rendering debug
/// information.
enum btDebugDrawModes
{
	/// @member No debug drawing.
	DBG_NoDebug = 0,
		/// @member Debug drawing of wireframe.
		DBG_DrawWireframe = 1,
		/// @member Debug drawing of axis-aligned bounding boxes (AABBs).
		DBG_DrawAabb = 2,
		/// @member Debug drawing of features as text.
		DBG_DrawFeaturesText = 4,
		/// @member Debug drawing of contact points.
		DBG_DrawContactPoints = 8,
		/// @member Debug drawing with no deactivation.
		DBG_NoDeactivation = 16,
		/// @member Debug drawing with no help text.
		DBG_NoHelpText = 32,
		/// @member Debug drawing of text.
		DBG_DrawText = 64,
		/// @member Debug drawing of profile timings.
		DBG_ProfileTimings = 128,
		/// @member Debug enabling of Separating Axis Theorem (SAT) comparison.
		DBG_EnableSatComparison = 256,
		/// @member Debug disabling of Bullet's Linear Complementarity Problem (LCP).
		DBG_DisableBulletLCP = 512,
		/// @member Debug enabling of Continuous Collision Detection (CCD).
		DBG_EnableCCD = 1024,
		/// @member Debug drawing of constraints.
		DBG_DrawConstraints = 0b100000000000,
		/// @member Debug drawing of constraint limits.
		DBG_DrawConstraintLimits = 0b1000000000000,
		/// @member Debug drawing of wireframe in a fast manner.
		DBG_FastWireframe = 0b10000000000000,
		/// @member Debug drawing of normals.
		DBG_DrawNormals = 0b100000000000000,
		/// @member Debug drawing of frames.
		DBG_DrawFrames = 0b1000000000000000,
		/// @member Maximum debug draw mode.
		DBG_MAX_DEBUG_DRAW_MODE
};

/// @func BBMOD_PhysicsWorldInfo()
///
/// @desc A struct that contains information for creating a physics world.
///
/// @see BBMOD_PhysicsEngine.create_physics_world
/// @see BBMOD_PhysicsWorld
function BBMOD_PhysicsWorldInfo() constructor
{
	/// @var {Struct.BBMOD_Vec3} The gravity vector for the physics world.
	/// Defaults to `(0, 0, -9.81)`.
	Gravity = new BBMOD_Vec3(0.0, 0.0, -9.81);

	/// @var {Real} The debug mode for the physics world. Defaults to `0` (no
	/// debug drawing).
	/// @see btDebugDrawModes
	DebugMode = 0;

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the physics world info into given buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_PhysicsWorldInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		Gravity.ToBuffer(_buffer, buffer_f64);
		buffer_write(_buffer, buffer_u64, DebugMode);
		return self;
	};

	/// @func to_abi()
	///
	/// @desc Converts the physics world info to a format suitable for passing
	/// to the native physics engine. This is used internally when creating a
	/// physics world, and is not intended to be called directly by user code.
	///
	/// @return {Pointer} The address of the buffer containing the physics
	/// world info.
	static to_abi = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		to_buffer(_scratchBuffer);
		return buffer_get_address(_scratchBuffer);
	};
}

/// @func BBMOD_PhysicsWorld()
///
/// @desc A struct that represents a physics world. It provides methods for
/// creating rigid bodies, constraints, and other physics-related objects, as well as simulating
/// the physics world and drawing debug information.
///
/// @see BBMOD_PhysicsEngine.create_physics_world
function BBMOD_PhysicsWorld() constructor
{
	__id = -1;

	/// @func get_gravity()
	///
	/// @desc Gets the gravity vector for the physics world.
	///
	/// @return {Struct.BBMOD_Vec3} The gravity vector for the physics world.
	static get_gravity = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		BBMOD_PhysicsWorld_GetGravity(__id, buffer_get_address(_scratchBuffer));
		return new BBMOD_Vec3().FromBuffer(_scratchBuffer, buffer_f64);
	};

	/// @func set_gravity(_gravity)
	///
	/// @desc Sets the gravity vector for the physics world.
	///
	/// @param {Struct.BBMOD_Vec3} _gravity The new gravity vector.
	///
	/// @return {Struct.BBMOD_PhysicsWorld} Returns `self`.
	static set_gravity = function (_gravity)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_gravity.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_PhysicsWorld_SetGravity(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func create_rigid_body(_info)
	///
	/// @desc Creates a new rigid body in the physics world with the specified
	/// information.
	///
	/// @param {Struct.BBMOD_RigidBodyInfo} _info Information for creating the
	/// rigid body.
	///
	/// @return {Struct.BBMOD_RigidBody} The created rigid body.
	static create_rigid_body = function (_info)
	{
		gml_pragma("forceinline");
		var _rigidBody = new BBMOD_RigidBody();
		_rigidBody.__id = BBMOD_PhysicsWorld_CreateRigidBody(__id, _info.to_abi());
		_rigidBody.__physicsWorld = self;
		return _rigidBody;
	};

	/// @func create_constraint(_info)
	///
	/// @desc Creates a new constraint in the physics world with the
	/// specified information.
	///
	/// @param {Struct.BBMOD_PhysicsConstraintInfo} _info Information for
	/// creating the constraint.
	///
	/// @return {Struct.BBMOD_PhysicsConstraint} The created constraint.
	static create_constraint = function (_info)
	{
		gml_pragma("forceinline");

		var _constraint = undefined;
		switch (_info.Type)
		{
			case BBMOD_EPhysicsConstraintType.ConeTwist:
				_constraint = new BBMOD_ConeTwistPhysicsConstraint();
				break;

			case BBMOD_EPhysicsConstraintType.Hinge:
				_constraint = new BBMOD_HingePhysicsConstraint();
				break;

			case BBMOD_EPhysicsConstraintType.Point:
				_constraint = new BBMOD_PointPhysicsConstraint();
				break;

			case BBMOD_EPhysicsConstraintType.SixDOF:
				_constraint = new BBMOD_SixDOFPhysicsConstraint();
				break;

			case BBMOD_EPhysicsConstraintType.Slider:
				_constraint = new BBMOD_SliderPhysicsConstraint();
				break;

			default:
				bbmod_assert(false, $"Invalid constraint type: {_info.__type}!");
				break;
		}

		_constraint.__id = BBMOD_PhysicsWorld_CreateConstraint(__id, _info.to_abi());
		_constraint.__physicsWorld = self;

		return _constraint;
	};

	/// @function create_terrain(_terrain)
	///
	/// @desc Creates a physical representation of the given terrain in the
	/// physics world.
	///
	/// @param {Struct.BBMOD_Terrain} _terrain The terrain to create the physics
	/// terrain from.
	///
	/// @return {Struct.BBMOD_PhysicsTerrain} The created physics terrain.
	static create_terrain = function (_terrain)
	{
		gml_pragma("forceinline");

		var _terrainWidth = _terrain.Size.X;
		var _terrainHeight = _terrain.Size.Y;

		var _buffer = buffer_create(1, buffer_grow, 1);
		buffer_write(_buffer, buffer_u32, _terrainWidth);
		buffer_write(_buffer, buffer_u32, _terrainHeight);
		buffer_write(_buffer, buffer_f64, _terrain.Position.X);
		buffer_write(_buffer, buffer_f64, _terrain.Position.Y);
		buffer_write(_buffer, buffer_f64, _terrain.Position.Z);
		buffer_write(_buffer, buffer_f64, _terrain.Scale.X);
		buffer_write(_buffer, buffer_f64, _terrain.Scale.Y);
		buffer_write(_buffer, buffer_f64, _terrain.Scale.Z);

		var _j = 0;
		repeat(_terrainHeight)
		{
			var _i = 0;
			repeat(_terrainWidth)
				{
					var _val = _terrain.get_height_index(_i, _j);
					buffer_write(_buffer, buffer_u8, _val);
					++_i;
				}
				++_j;
		}

		var _physicsTerrain = new BBMOD_PhysicsTerrain();
		_physicsTerrain.__id = BBMOD_PhysicsWorld_CreateTerrain(__id, buffer_get_address(_buffer));
		_physicsTerrain.__physicsWorld = self;
		_physicsTerrain.__buffer = _buffer;
		return _physicsTerrain;
	};

	/// @function create_vehicle(_info)
	///
	/// @desc Creates a new vehicle in the physics world with the specified
	/// information.
	///
	/// @param {Struct.BBMOD_PhysicsVehicleInfo} _info Information for creating
	/// the vehicle.
	///
	/// @return {Struct.BBMOD_PhysicsVehicle} The created physics vehicle.
	static create_vehicle = function (_info)
	{
		gml_pragma("forceinline");
		var _vehicle = new BBMOD_PhysicsVehicle();
		_vehicle.__id = BBMOD_PhysicsWorld_CreateVehicle(__id, _info.to_abi());
		_vehicle.__physicsWorld = self;
		return _vehicle;
	};

	/// @func simulate(_timeStep[, _maxSubSteps])
	///
	/// @desc Simulates the physics world for the given time step.
	///
	/// @param {Real} _timeStep The time step to simulate the physics world for.
	/// @param {Real} [_maxSubSteps] The maximum number of sub-steps to perform.
	/// Defaults to `1`.
	///
	/// @return {Struct.BBMOD_PhysicsWorld} Returns `self`.
	static simulate = function (_timeStep, _maxSubSteps = 1)
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsWorld_Simulate(__id, _timeStep, _maxSubSteps);
		return self;
	};

	// TODO: Add ray_test, contact_test, sweep_test

	/// @func draw_debug()
	///
	/// @desc Draws the debug information for the physics world.
	///
	/// @return {Struct.BBMOD_PhysicsWorld} Returns `self`.
	static draw_debug = function ()
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsWorld_DrawDebug(__id);
		var _size = BBMOD_PhysicsWorld_GetDebugDrawSize(__id);
		if (_size > 0)
		{
			var __scratchBuffer = bbmod_get_scratch_buffer(_size);
			BBMOD_PhysicsWorld_GetDebugDrawToBuffer(__id, buffer_get_address(__scratchBuffer));
			buffer_set_used_size(__scratchBuffer, _size);
			var _vbuffer = vertex_create_buffer_from_buffer(__id, BBMOD_VFORMAT_DEBUG.Raw);
			vertex_freeze(_vbuffer);
			shader_set(BBMOD_ShDebug);
			gpu_push_state();
			//gpu_set_zwriteenable(true);
			//gpu_set_ztestenable(true);
			vertex_submit(_vbuffer, pr_linelist, -1);
			gpu_pop_state();
			shader_reset();
			vertex_delete_buffer(_vbuffer);
		}
		return self;
	};

	static destroy = function ()
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsWorld_Destroy(__id);
		__id = -1;
		return undefined;
	};
}
