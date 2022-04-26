/// @func BBMOD_ParticleModule()
/// @desc Base struct for particle modules. These are composed into particle
/// system to define behavior of their particles.
/// @see BBMOD_ParticleSystem
function BBMOD_ParticleModule() constructor
{
	/// @var {Bool} If `true` then the module is enabled. Defaults value
	/// is `true`.
	Enabled = true;

	// TODO: Fix docs

	/// @func on_start(_emitter)
	/// @desc Executed when an emitter starts emitting particles.
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter The particle emitter.
	static on_start = undefined;/*function (_emitter) {
	};*/

	/// @func on_update(_emitter, _deltaTime)
	/// @desc Executed on every update of a particle emitter.
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter The particle emitter.
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	static on_update = undefined;/*function (_emitter, _deltaTime) {
	};*/

	/// @func on_finish(_emitter)
	/// @desc Executed at the end of the emit cycle.
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter The particle emitter.
	static on_finish = undefined;/*function (_emitter) {
	};*/

	/// @func on_particle_start(_particle)
	/// @desc Executed when a new particle is spawned.
	/// @param {Struct.BBMOD_Particle} _particle The spawned particle.
	static on_particle_start = undefined;/*function (_particle) {
	};*/

	/// @func on_particle_update(_particle, _deltaTime)
	/// @desc Executed on every update of a particle.
	/// @param {Struct.BBMOD_Particle} _particle The updated particle.
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	static on_particle_update = undefined;/*function (_particle, _deltaTime) {
	};*/

	/// @func on_particle_finish(_particle)
	/// @desc Executed on particle's death.
	/// @param {Struct.BBMOD_Particle} _particle The dead particle.
	static on_particle_finish = undefined;/*function (_particle) {
	};*/
}