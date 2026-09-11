/// @module Particles

// Feather ignore GM1021

/// @func BBMOD_ParticleSystem(_model, _material, _particleCount[, _batchSize])
///
/// @extends {BBMOD_Resource}
///
/// @implements {BBMOD_IDestructible}
///
/// @desc A collection of particle modules that together define behavior of
/// particles.
///
/// @param {Struct.BBMOD_Model} _model The particle model.
/// @param {Struct.BBMOD_Material} _material The material used by the particle
/// system.
/// @param {Real} _particleCount Maximum number of particles alive in the
/// system.
/// @param {Real} [_batchSize] Number of particles rendered in a single draw
/// call. Default value is 32.
///
/// @see BBMOD_ParticleModule
/// @see BBMOD_ParticleEmitter
/// @see BBMOD_MODEL_PARTICLE
/// @see BBMOD_MATERIAL_PARTICLE_LIT
/// @see BBMOD_MATERIAL_PARTICLE_UNLIT
function BBMOD_ParticleSystem(
	_model = undefined,
	_material = undefined,
	_particleCount = 0,
	_batchSize = 32
): BBMOD_Resource() constructor
{
	static Resource_destroy = destroy;

	/// @var {Struct.BBMOD_Model} The model used by the particle batch.
	Model = _model;

	/// @var {Real} Number of particles rendered in one batch.
	BatchSize = _batchSize;

	/// @var {Struct.BBMOD_Material} _material The material used by the particle
	/// system.
	Material = _material;

	/// @var {Real} Maximum number of particles alive in the system.
	/// @readonly
	ParticleCount = _particleCount;

	/// @var {Bool} Use `true` to sort particles back to front. This should be
	/// enabled if you would like to use alpha blending. Default value is `false`.
	Sort = false;

	/// @var {Real} How long in seconds is the system emitting particles for.
	/// Default value is 5s.
	Duration = 5.0;

	/// @var {Bool} If `true` then the emission cycle repeats after the duration.
	/// Default value is `false`.
	Loop = false;

	/// @var {Struct.BBMOD_DynamicBatch}
	/// @private
	__dynamicBatch = (_model != undefined)
		? new BBMOD_DynamicBatch(_model, _batchSize).freeze() : undefined;

	/// @var {Array<Struct.BBMOD_ParticleModule>} An array of modules
	/// affecting individual particles in this system.
	/// @readonly
	Modules = [];

	/// @var {Array<Struct.BBMOD_ParticleModule>}
	/// @private
	__modulesOnParticleStart = [];

	/// @var {Array<Struct.BBMOD_ParticleModule>}
	/// @private
	__modulesOnParticleFinish = [];

	/// @var {Array<Bool>}
	/// @private
	__moduleHasStart = [];

	/// @var {Array<Bool>}
	/// @private
	__moduleHasUpdate = [];

	/// @var {Array<Bool>}
	/// @private
	__moduleHasFinish = [];

	/// @var {Array<Struct.BBMOD_ParticleModule>}
	/// @private
	__moduleCallbacksSource = undefined;

	/// @var {Real}
	/// @private
	__moduleCallbacksLength = -1;

	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_string, "BBPART");
		buffer_write(_buffer, buffer_u32, 1);
		buffer_write(_buffer, buffer_u32, ParticleCount);
		buffer_write(_buffer, buffer_u32, BatchSize);
		buffer_write(_buffer, buffer_bool, Sort);
		buffer_write(_buffer, buffer_f64, Duration);
		buffer_write(_buffer, buffer_bool, Loop);
		buffer_write(_buffer, buffer_string,
			(Model != undefined && Model.Path != undefined) ? Model.Path : "");
		buffer_write(_buffer, buffer_string,
			(Material != undefined && Material.Path != undefined) ? Material.Path : "");
		buffer_write(_buffer, buffer_u32, array_length(Modules));
		for (var i = 0; i < array_length(Modules); ++i)
		{
			var _module = Modules[i];
			var _constructorName = instanceof(_module);
			if (_constructorName == undefined || _constructorName == "struct")
			{
				throw new BBMOD_Exception("Particle module has no constructor.");
			}
			if (_constructorName == "BBMOD_TerrainCollisionModule"
				|| _constructorName == "BBMOD_CollisionEventModule")
			{
				throw new BBMOD_Exception(
					"Particle module does not support binary serialization: "
					+ _constructorName);
			}
			if (!variable_struct_exists(_module, "to_buffer")
				|| !variable_struct_exists(_module, "from_buffer")
				|| !is_method(_module.to_buffer)
				|| !is_method(_module.from_buffer))
			{
				throw new BBMOD_Exception(
					"Particle module does not support binary serialization: "
					+ _constructorName);
			}
			buffer_write(_buffer, buffer_string, _constructorName);
			_module.to_buffer(_buffer);
		}
		IsLoaded = true;
		return self;
	};

	static from_buffer = function (_buffer)
	{
		if (buffer_read(_buffer, buffer_string) != "BBPART")
		{
			throw new BBMOD_Exception("Invalid BBPART resource header.");
		}
		if (buffer_read(_buffer, buffer_u32) != 1)
		{
			throw new BBMOD_Exception("Unsupported BBPART resource version.");
		}
		ParticleCount = buffer_read(_buffer, buffer_u32);
		BatchSize = buffer_read(_buffer, buffer_u32);
		Sort = buffer_read(_buffer, buffer_bool);
		Duration = buffer_read(_buffer, buffer_f64);
		Loop = buffer_read(_buffer, buffer_bool);
		var _modelPath = buffer_read(_buffer, buffer_string);
		if (_modelPath != "")
		{
			Model = (__manager != undefined)
				? __manager.load_sync(_modelPath)
				: new BBMOD_Model(_modelPath);
			__dynamicBatch = new BBMOD_DynamicBatch(Model, BatchSize).freeze();
		}
		var _materialPath = buffer_read(_buffer, buffer_string);
		if (_materialPath != "")
		{
			Material = (__manager != undefined)
				? __manager.load_sync(_materialPath)
				: new BBMOD_Material().from_file(_materialPath);
		}
		var _moduleCount = buffer_read(_buffer, buffer_u32);
		if (_moduleCount > 100000)
		{
			throw new BBMOD_Exception("Invalid particle module count.");
		}
		Modules = [];
		for (var i = 0; i < _moduleCount; ++i)
		{
			var _constructorName = buffer_read(_buffer, buffer_string);
			if (_constructorName == "BBMOD_TerrainCollisionModule"
				|| _constructorName == "BBMOD_CollisionEventModule")
			{
				throw new BBMOD_Exception(
					"Particle module does not support binary serialization: "
					+ _constructorName);
			}
			var _constructor = asset_get_index(_constructorName);
			if (_constructor == -1)
			{
				throw new BBMOD_Exception("Unknown particle module: " + _constructorName);
			}
			add_modules(new _constructor().from_buffer(_buffer));
		}
		__rebuild_module_callbacks();
		IsLoaded = true;
		return self;
	};

	/// @func __rebuild_module_callbacks()
	///
	/// @desc Rebuilds internal module callback caches.
	///
	/// @return {Struct.BBMOD_ParticleSystem} Returns `self`.
	///
	/// @private
	static __rebuild_module_callbacks = function ()
	{
		var _modules = Modules;
		var _moduleCount = array_length(_modules);

		var _modulesOnParticleStart = [];
		var _modulesOnParticleFinish = [];
		var _moduleHasStart = array_create(_moduleCount, false);
		var _moduleHasUpdate = array_create(_moduleCount, false);
		var _moduleHasFinish = array_create(_moduleCount, false);

		var i = 0;
		repeat(_moduleCount)
		{
			var _module = _modules[i];
			_moduleHasStart[@ i] = (_module.on_start != undefined);
			_moduleHasUpdate[@ i] = (_module.on_update != undefined);
			_moduleHasFinish[@ i] = (_module.on_finish != undefined);

			if (_module.on_particle_start != undefined)
			{
				array_push(_modulesOnParticleStart, _module);
			}

			if (_module.on_particle_finish != undefined)
			{
				array_push(_modulesOnParticleFinish, _module);
			}

			++i;
		}

		__modulesOnParticleStart = _modulesOnParticleStart;
		__modulesOnParticleFinish = _modulesOnParticleFinish;
		__moduleHasStart = _moduleHasStart;
		__moduleHasUpdate = _moduleHasUpdate;
		__moduleHasFinish = _moduleHasFinish;
		__moduleCallbacksSource = _modules;
		__moduleCallbacksLength = _moduleCount;

		return self;
	};

	/// @func __ensure_module_callbacks()
	///
	/// @desc Lazily refreshes callback caches when module list changes.
	///
	/// @return {Struct.BBMOD_ParticleSystem} Returns `self`.
	///
	/// @private
	static __ensure_module_callbacks = function ()
	{
		var _modules = Modules;
		if (_modules != __moduleCallbacksSource
			|| array_length(_modules) != __moduleCallbacksLength)
		{
			__rebuild_module_callbacks();
		}
		return self;
	};

	/// @func add_modules(_module...)
	///
	/// @desc Adds modules to the particle system.
	///
	/// @param {Struct.BBMOD_ParticleModule} _module The module to add.
	///
	/// @return {Struct.BBMOD_ParticleSystem} Returns `self`.
	///
	/// @see BBMOD_ParticleModule
	static add_modules = function (_module)
	{
		gml_pragma("forceinline");
		var i = 0;
		repeat(argument_count)
		{
			array_push(Modules, argument[i++]);
		}
		__rebuild_module_callbacks();
		return self;
	};

	__rebuild_module_callbacks();

	static destroy = function ()
	{
		Resource_destroy();
		if (__dynamicBatch != undefined)
		{
			__dynamicBatch.destroy();
		}
		return undefined;
	};
}
