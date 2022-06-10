/// @func BBMOD_MixInitialColorModule([_from[, _to]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that randomly blends initial color of particles.
///
/// @param {Struct.BBMOD_Color} [_from] The color to blend from. Defaults to
/// {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Color} [_to] The coolor to blend to. Defaults to `_from`.
///
/// @see BBMOD_EParticle.ColorR
/// @see BBMOD_EParticle.ColorG
/// @see BBMOD_EParticle.ColorB
/// @see BBMOD_EParticle.ColorA
function BBMOD_MixInitialColorModule(_from=BBMOD_C_WHITE, _to=_from.Clone())
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Color} The color to blend from. Default value is
	/// {@link BBMOD_C_WHITE}.
	From = _from;

	/// @var {Struct.BBMOD_Color} The color to blend to. Default value is the
	/// same as {@link BBMOD_MixInitialColorModule.From}.
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _from = From;
		var _to = To;
		var _factor = random(1.0);
		var _particles = _emitter.Particles;
		_particles[# BBMOD_EParticle.ColorR, _particleIndex] = lerp(_from.Red, _to.Red, _factor);
		_particles[# BBMOD_EParticle.ColorG, _particleIndex] = lerp(_from.Green, _to.Green, _factor);
		_particles[# BBMOD_EParticle.ColorB, _particleIndex] = lerp(_from.Blue, _to.Blue, _factor);
		_particles[# BBMOD_EParticle.ColorA, _particleIndex] = lerp(_from.Alpha, _to.Alpha, _factor);
	};
}
