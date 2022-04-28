/// @func BBMOD_InitialHealthModule([_health])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_health]
function BBMOD_InitialHealthModule(_health=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Health = _health;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _health = Health;
		_particles[# BBMOD_EParticle.Health, _particleIndex] = _health;
		_particles[# BBMOD_EParticle.HealthLeft, _particleIndex] = _health;
	};
}
