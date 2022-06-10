/// @func BBMOD_InitialHealthModule([_health])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that sets initial health of particles.
///
/// @param {Real} [_health] The initial health of particles. Defaults to 1.0.
///
/// @see BBMOD_EParticle.Health
/// @see BBMOD_EParticle.HealthLeft
function BBMOD_InitialHealthModule(_health=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real} The initial health of particles. Default value is 1.0.
	Health = _health;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _health = Health;
		_particles[# BBMOD_EParticle.Health, _particleIndex] = _health;
		_particles[# BBMOD_EParticle.HealthLeft, _particleIndex] = _health;
	};
}
