/// @func BBMOD_MixInitialHealthModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_from]
/// @param {Real} [_to]
function BBMOD_MixInitialHealthModule(_from=1.0, _to=_from)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	From = _from;

	/// @var {Real}
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _health = lerp(From, To, random(1.0));
		_particles[# BBMOD_EParticle.Health, _particleIndex] = _health;
		_particles[# BBMOD_EParticle.HealthLeft, _particleIndex] = _health;
	};
}
