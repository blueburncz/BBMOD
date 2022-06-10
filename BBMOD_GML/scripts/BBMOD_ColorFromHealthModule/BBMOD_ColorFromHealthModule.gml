/// @func BBMOD_ColorFromHealthModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc A particle module that controls particles' color based on their
/// remaining health.
/// @param {Struct.BBMOD_Color} [_from] The color of particles when they have full health.
/// Defaults to {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Color} [_to] The color of particles when they have no health left.
/// Defaults to `_from`.
/// @see BBMOD_EParticle.ColorR
/// @see BBMOD_EParticle.ColorG
/// @see BBMOD_EParticle.ColorB
/// @see BBMOD_EParticle.ColorA
/// @see BBMOD_EParticle.HealthLeft
function BBMOD_ColorFromHealthModule(_from=BBMOD_C_WHITE, _to=_from)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Color} The color of particles when they have full health.
	/// Default value is {@link BBMOD_C_WHITE}.
	From = _from;

	/// @var {Struct.BBMOD_Color} The color of particles when they have no health left.
	/// Default value is the same as {@link BBMOD_ColorFromHealthModule.From}.
	To = _to;

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
