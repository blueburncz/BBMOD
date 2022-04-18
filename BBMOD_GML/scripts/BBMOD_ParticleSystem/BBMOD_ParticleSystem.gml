/// @func BBMOD_ParticleSystem(_model, _material, _particleCount[, _batchSize])
/// @extends BBMOD_Class
/// @desc 
/// @param {Struct.BBMOD_Model} _model The particle model.
/// @param {Struct.BBMOD_Material} _material The material used by the particle system.
/// @param {Real} _particleCount Maximum number of particles alive in the system.
/// @param {Real} [_batchSize] Number of particles rendered in a single draw call.
/// Default value is 64.
/// @see BBMOD_ParticleModule
/// @see BBMOD_ParticleEmitter
/// @see BBMOD_MODEL_PARTICLE
function BBMOD_ParticleSystem(_model, _material, _particleCount, _batchSize=64)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Struct.BBMOD_Material} _material The material used by the particle system.
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
	DynamicBatch = new BBMOD_DynamicBatch(_model, _batchSize).freeze();

	/// @var {Array<Struct.BBMOD_ParticleModule>} An array of modules
	/// affecting individual particles in this system.
	/// @readonly
	Modules = [];

	/// @func add_module(_module)
	/// @desc Adds a module to the particle system.
	/// @param {Struct.BBMOD_ParticleModule} _module The module to add.
	/// @return {Struct.BBMOD_ParticleSystem} Returns `self`.
	/// @see BBMOD_ParticleModule
	static add_module = function (_module) {
		gml_pragma("forceinline");
		array_push(Modules, _module);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		DynamicBatch.destroy();
	};
}