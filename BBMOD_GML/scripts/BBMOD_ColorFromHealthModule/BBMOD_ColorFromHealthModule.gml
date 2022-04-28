/// @func BBMOD_ColorFromHealthModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Color/Undefined} [_from]
/// @param {Struct.BBMOD_Color/Undefined} [_to]
function BBMOD_ColorFromHealthModule(_from=undefined, _to=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Color}
	From = _from ?? BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Color}
	To = _to ?? From;

	static on_update = function (_emitter, _deltaTime) {
		var _particles = _emitter.Particles;
		var _from = From;
		var _fromR = _from.Red;
		var _fromG = _from.Green;
		var _fromB = _from.Blue;
		var _fromA = _from.Alpha;
		var _to = To;
		var _toR = _to.Red;
		var _toG = _to.Green;
		var _toB = _to.Blue;
		var _toA = _to.Alpha;

		var _particleIndex = 0;
		repeat (_emitter.ParticlesAlive)
		{
			var _factor = clamp(_particles[# BBMOD_EParticle.HealthLeft, _particleIndex]
				/ _particles[# BBMOD_EParticle.Health, _particleIndex], 0.0, 1.0);
			_particles[# BBMOD_EParticle.ColorR, _particleIndex] = lerp(_toR, _fromR, _factor);
			_particles[# BBMOD_EParticle.ColorG, _particleIndex] = lerp(_toG, _fromG, _factor);
			_particles[# BBMOD_EParticle.ColorB, _particleIndex] = lerp(_toB, _fromB, _factor);
			_particles[# BBMOD_EParticle.ColorA, _particleIndex] = lerp(_toA, _fromA, _factor);
			++_particleIndex;
		}
	};
}
