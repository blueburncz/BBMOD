/// @func BBMOD_MixInitialHealthModule([_from[, _to]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that randomly sets initial health of particles.
///
/// @param {Real} [_from] The minimum particle health. Defaults to 1.0.
/// @param {Real} [_to] The maximum particle health. Defaults to `_from`.
///
/// @see BBMOD_EParticle.Health
/// @see BBMOD_EParticle.HealthLeft
function BBMOD_MixInitialHealthModule(_from=1.0, _to=_from)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real} The minimum particle health. Default value is 1.0.
	From = _from;

	/// @var {Real} The maximum particle health. Default value is the same as
	/// {@link BBMOD_MixInitialHealthModule.From}.
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _health = lerp(From, To, random(1.0));
		_particles[# BBMOD_EParticle.Health, _particleIndex] = _health;
		_particles[# BBMOD_EParticle.HealthLeft, _particleIndex] = _health;
	};
}
