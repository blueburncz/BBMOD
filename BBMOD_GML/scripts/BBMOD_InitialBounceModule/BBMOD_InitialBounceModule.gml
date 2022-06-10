/// @func BBMOD_InitialBounceModule([_bounce])
/// @extends BBMOD_ParticleModule
/// @desc A particle module that sets an initial value of particles'
/// bounciness property.
/// @param {Real} [_bounce] The bounciness of spawned particles. The greater
/// the value, the more the particles bounce on collision. Defaults to 1.0.
/// @see BBMOD_EParticle.Bounce
function BBMOD_InitialBounceModule(_bounce=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real} The bounciness of spawned particles.
	/// @see BBMOD_EParticle.Bounce
	Bounce = _bounce;

	static on_particle_start = function (_emitter, _particleIndex) {
		_emitter.Particles[# BBMOD_EParticle.Bounce, _particleIndex] = Bounce;
	};
}
