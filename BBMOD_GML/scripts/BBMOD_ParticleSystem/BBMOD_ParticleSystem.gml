/// @module Particles

/// @func BBMOD_ParticleSystem(_model, _material, _particleCount[, _batchSize])
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
function BBMOD_ParticleSystem(_model, _material, _particleCount, _batchSize = 32) constructor
{
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
	__dynamicBatch = new BBMOD_DynamicBatch(_model, _batchSize).freeze();

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
		__dynamicBatch = __dynamicBatch.destroy();
		return undefined;
	};
}
