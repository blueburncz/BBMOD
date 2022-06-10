/// @func BBMOD_InitialMassModule([_mass])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_mass]
function BBMOD_InitialMassModule(_mass=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Mass = _mass;

	static on_particle_start = function (_emitter, _particleIndex) {
		_emitter.Particles[# BBMOD_EParticle.Mass, _particleIndex] = Mass;
	};
}
