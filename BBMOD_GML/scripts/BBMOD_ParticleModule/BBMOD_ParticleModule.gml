/// @func BBMOD_ParticleModule()
/// @desc
/// @see BBMOD_ParticleSystem
function BBMOD_ParticleModule() constructor
{
	/// @var {Bool} If `true` then the module is enabled. Defaults value
	/// is `true`.
	Enabled = true;

	/// @func on_start(_emitter)
	/// @desc
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter
	static on_start = function (_emitter) {
	};

	/// @func on_update(_emitter, _deltaTime)
	/// @desc
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter
	/// @param {Real} _deltaTime
	static on_update = function (_emitter, _deltaTime) {
	};

	/// @func on_finish(_emitter)
	/// @desc
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter
	static on_finish = function (_emitter) {
	};

	/// @func on_particle_start(_particle)
	/// @desc
	/// @param {Struct.BBMOD_Particle} _particle
	static on_particle_start = function (_particle) {
	};

	/// @func on_particle_update(_particle, _deltaTime)
	/// @desc
	/// @param {Struct.BBMOD_Particle} _particle
	/// @param {Real} _deltaTime
	static on_particle_update = function (_particle, _deltaTime) {
	};

	/// @func on_particle_fiinish(_particle)
	/// @desc
	/// @param {Struct.BBMOD_Particle} _particle
	static on_particle_fiinish = function (_particle) {
	};
}