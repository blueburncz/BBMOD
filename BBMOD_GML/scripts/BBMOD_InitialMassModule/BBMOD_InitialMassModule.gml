/// @func BBMOD_InitialMassModule([_mass])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that sets an initial value of particles' mass.
///
/// @param {Real} [_mass] The initial particle mass. Defaults to 1.0.
///
/// @see BBMOD_EParticle.Mass
function BBMOD_InitialMassModule(_mass=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real} The initial particle mass. Default value is 1.0.
	Mass = _mass;

	static on_particle_start = function (_emitter, _particleIndex) {
		_emitter.Particles[# BBMOD_EParticle.Mass, _particleIndex] = Mass;
	};
}
