/// @func BBMOD_InitialColorModule([_color])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Color/Undefined} [_color]
function BBMOD_InitialColorModule(_color)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Color}
	Color = _color ?? BBMOD_C_WHITE;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _color = Color;
		var _particles = _emitter.Particles;
		_particles[# BBMOD_EParticle.ColorR, _particleIndex] = _color.Red;
		_particles[# BBMOD_EParticle.ColorG, _particleIndex] = _color.Green;
		_particles[# BBMOD_EParticle.ColorB, _particleIndex] = _color.Blue;
		_particles[# BBMOD_EParticle.ColorA, _particleIndex] = _color.Alpha;
	};
}
