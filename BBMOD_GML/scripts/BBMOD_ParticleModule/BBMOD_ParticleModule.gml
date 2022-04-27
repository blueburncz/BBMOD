/// @func BBMOD_ParticleModule()
/// @desc Base struct for particle modules. These are composed into particle
/// system to define behavior of their particles.
/// @see BBMOD_ParticleSystem
function BBMOD_ParticleModule() constructor
{
	/// @var {Bool} If `true` then the module is enabled. Defaults value
	/// is `true`.
	Enabled = true;

	// TODO: Add docs

	// Args: _emitter
	static on_start = undefined;

	// Args: _emitter, _deltaTime
	static on_update = undefined;

	// Args: _emitter
	static on_finish = undefined;

	// Args: _emitter, _particleId
	static on_particle_start = undefined;

	// Args: _emitter, _particleId
	static on_particle_finish = undefined;
}