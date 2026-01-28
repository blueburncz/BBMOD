/// @module Physics

/// @enum Enum representing debug draw modes for rendering debug information.
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

function BBMOD_PhysicsWorldInfo() constructor
{
	Gravity = new BBMOD_Vec3(0.0, 0.0, -9.81);
	DebugMode = 0;

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the physics world info into given buffer.
	///
	/// @param {Id.Buffer} The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_PhysicsWorldInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		Gravity.ToBuffer(_buffer, buffer_f64);
		buffer_write(_buffer, buffer_u64, DebugMode);
		return self;
	};
}

function BBMOD_PhysicsWorld() constructor
{
	__id = -1;

	/// @func set_gravity(_gravity)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_Vec3} _gravity
	///
	/// @return {Struct.BBMOD_PhysicsWorld} Returns `self`.
	static set_gravity = function (_gravity)
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsWorld_SetGravity(__id, _gravity.X, _gravity.Y, _gravity.Z);
		return self;
	};

	/// @func create_rigid_body(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_RigidBodyInfo} _info
	///
	/// @return {Struct.BBMOD_RigidBody}
	static create_rigid_body = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _rigidBody = new BBMOD_RigidBody();
		_rigidBody.__id = BBMOD_PhysicsWorld_CreateRigidBody(__id, buffer_get_address(_scratchBuffer));
		return _rigidBody;
	};

	/// @func create_point_constraint(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_PointPhysicsConstraintInfo} _info
	///
	/// @return {Struct.BBMOD_PointPhysicsConstraint}
	static create_point_constraint = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _constraint = new BBMOD_PointPhysicsConstraint();
		_constraint.__id = BBMOD_PhysicsWorld_CreatePointConstraint(__id, buffer_get_address(_scratchBuffer));
		return _constraint;
	};

	/// @func create_hinge_constraint(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_HingePhysicsConstraintInfo} _info
	///
	/// @return {Struct.BBMOD_HingePhysicsConstraint}
	static create_hinge_constraint = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _constraint = new BBMOD_HingePhysicsConstraint();
		_constraint.__id = BBMOD_PhysicsWorld_CreateHingeConstraint(__id, buffer_get_address(_scratchBuffer));
		return _constraint;
	};

	/// @func create_slider_constraint(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_SliderPhysicsConstraintInfo} _info
	///
	/// @return {Struct.BBMOD_SliderPhysicsConstraint}
	static create_slider_constraint = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _constraint = new BBMOD_SliderPhysicsConstraint();
		_constraint.__id = BBMOD_PhysicsWorld_CreateSliderConstraint(__id, buffer_get_address(_scratchBuffer));
		return _constraint;
	};

	/// @func create_cone_twist_constraint(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_ConeTwistPhysicsConstraintInfo} _info
	///
	/// @return {Struct.BBMOD_ConeTwistPhysicsConstraint}
	static create_cone_twist_constraint = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _constraint = new BBMOD_ConeTwistPhysicsConstraint();
		_constraint.__id = BBMOD_PhysicsWorld_CreateConeTwistConstraint(__id, buffer_get_address(_scratchBuffer));
		return _constraint;
	};

	/// @func create_six_dof_constraint(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_SixDOFPhysicsConstraintInfo} _info
	///
	/// @return {Struct.BBMOD_SixDOFPhysicsConstraint}
	static create_six_dof_constraint = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _constraint = new BBMOD_SixDOFPhysicsConstraint();
		_constraint.__id = BBMOD_PhysicsWorld_CreateSixDOFConstraint(__id, buffer_get_address(_scratchBuffer));
		return _constraint;
	};

	/// @function create_terrain(_terrain)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_Terrain} _terrain
	///
	/// @return {Struct.BBMOD_PhysicsTerrain}
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
		repeat (_terrainHeight)
		{
			var _i = 0;
			repeat (_terrainWidth)
			{
				var _val = _terrain.get_height_index(_i, _j);
				buffer_write(_buffer, buffer_u8, _val);
				++_i;
			}
			++_j;
		}

		var _physicsTerrain = new BBMOD_PhysicsTerrain();
		_physicsTerrain.__id = BBMOD_PhysicsWorld_CreateTerrain(__id, buffer_get_address(_buffer));
		_physicsTerrain.__buffer = _buffer;
		return _physicsTerrain;
	};

	/// @function create_vehicle(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_PhysicsVehicleInfo} _info
	///
	/// @return {Struct.BBMOD_PhysicsVehicle}
	static create_vehicle = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _vehicle = new BBMOD_PhysicsVehicle();
		_vehicle.__id = BBMOD_PhysicsWorld_CreateVehicle(__id, buffer_get_address(_scratchBuffer));
		return _vehicle;
	};

	/// @func simulate(_timeStep[, _maxSubSteps])
	///
	/// @desc
	///
	/// @param {Real} _timeStep
	/// @param {Real} [_maxSubSteps]
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
	/// @desc
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

	/// @func destroy()
	///
	/// @desc
	///
	/// @return {Undefined}
	static destroy = function ()
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsWorld_Destroy(__id);
		return undefined;
	};
}
