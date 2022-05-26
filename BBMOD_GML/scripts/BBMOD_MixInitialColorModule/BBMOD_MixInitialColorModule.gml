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
