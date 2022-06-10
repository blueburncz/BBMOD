/// @func BBMOD_InitialColorModule([_color])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that sets an inital color of particles.
///
/// @param {Struct.BBMOD_Color} [_color] The initial color of particles. Defaults
/// to {@link BBMOD_C_WHITE}.
///
/// @see BBMOD_EParticle.ColorR
/// @see BBMOD_EParticle.ColorG
/// @see BBMOD_EParticle.ColorB
/// @see BBMOD_EParticle.ColorA
function BBMOD_InitialColorModule(_color=BBMOD_C_WHITE)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Color} The initial color of particles.
	Color = _color;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _color = Color;
		var _particles = _emitter.Particles;
		_particles[# BBMOD_EParticle.ColorR, _particleIndex] = _color.Red;
		_particles[# BBMOD_EParticle.ColorG, _particleIndex] = _color.Green;
		_particles[# BBMOD_EParticle.ColorB, _particleIndex] = _color.Blue;
		_particles[# BBMOD_EParticle.ColorA, _particleIndex] = _color.Alpha;
	};
}
