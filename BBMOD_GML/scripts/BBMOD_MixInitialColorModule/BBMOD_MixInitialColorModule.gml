/// @func BBMOD_MixInitialColorModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Color/Undefined} [_from]
/// @param {Struct.BBMOD_Color/Undefined} [_to]
function BBMOD_MixInitialColorModule(_from=undefined, _to=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Color}
	From = _from ?? BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Color}
	To = _to ?? From;

	static on_particle_start = function (_emitter, _particleId) {
		var _color = From.Mix(To, random(1.0));
		_emitter.Particles[# BBMOD_EParticle.ColorR, _particleId] = _color.Red;
		_emitter.Particles[# BBMOD_EParticle.ColorG, _particleId] = _color.Green;
		_emitter.Particles[# BBMOD_EParticle.ColorB, _particleId] = _color.Blue;
		_emitter.Particles[# BBMOD_EParticle.ColorA, _particleId] = _color.Alpha;
	};
}
