/// @func BBMOD_InitialBounceModule([_bounce])
/// @extends BBMOD_ParticleModule
/// @param {Real} [_bounce]
function BBMOD_InitialBounceModule(_bounce=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Bounce = _bounce;

	static on_particle_start = function (_emitter, _particleIndex) {
		_emitter.Particles[# BBMOD_EParticle.Bounce, _particleIndex] = Bounce;
	};
}