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

	/// @func on_start_particle(_particle)
	/// @desc
	/// @param {Struct.BBMOD_Particle} _particle
	static on_start_particle = function (_particle) {
	};

	/// @func on_update(_emitter, _deltaTime)
	/// @desc
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter
	/// @param {Real} _deltaTime
	static on_update = function (_emitter, _deltaTime) {
	};

	/// @func on_update_particle(_particle, _deltaTime)
	/// @desc
	/// @param {Struct.BBMOD_Particle} _particle
	/// @param {Real} _deltaTime
	static on_update_particle = function (_particle, _deltaTime) {
	};

	/// @func on_finish(_emitter)
	/// @desc
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter
	static on_finish = function (_emitter) {
	};

	/// @func on_finish_particle(_particle)
	/// @desc
	/// @param {Struct.BBMOD_Particle} _particle
	static on_finish_particle = function (_particle) {
	};
}