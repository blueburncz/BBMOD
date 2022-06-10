/// @func BBMOD_ColorFromSpeedModule([_from[, _to[, _min[, _max]]])
/// @extends BBMOD_ParticleModule
/// @desc A particle module that controls particles' color based on their speed.
/// @param {Struct.BBMOD_Color} [_from] The color to blend from. Defaults to
/// {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Color} [_to] The color to blend to. Defaults to `_from`.
/// @param {Real} [_min] If the particles' speed is less than this, then their
/// color is equal to `_from`. Defaults to 0.0.
/// @param {Real} [_max] If the particles' speed is greater than this, then their
/// color is equal to `_to`. Defaults to 1.0.
/// @see BBMOD_EParticle.ColorR
/// @see BBMOD_EParticle.ColorG
/// @see BBMOD_EParticle.ColorB
/// @see BBMOD_EParticle.ColorA
/// @see BBMOD_EParticle.VelocityX
/// @see BBMOD_EParticle.VelocityY
/// @see BBMOD_EParticle.VelocityZ
function BBMOD_ColorFromSpeedModule(_from=BBMOD_C_WHITE, _to=_from, _min=0.0, _max=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Color} The color to blend from. Default value
	/// is {@link BBMOD_C_WHITE}.
	From = _from;

	/// @var {Struct.BBMOD_Color} The color to blend to. Default value
	/// is the same as {@link BBMOD_ColorFromSpeedModule.From}.
	To = _to;

	/// @var {Real} If the particles' speed is less than this, then their
	/// color is equal to {@link BBMOD_ColorFromSpeedModule.From}. Default
	/// value is 0.0.
	Min = _min;

	/// @var {Real} If the particles' speed is greater than this, then their
	/// color is equal to {@link BBMOD_ColorFromSpeedModule.To}. Default
	/// value is 1.0.
	Max = _max;

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
		var _min = Min;
		var _div = Max - _min;

		var _particleIndex = 0;
		repeat (_emitter.ParticlesAlive)
		{
			var _velX = _particles[# BBMOD_EParticle.VelocityX, _particleIndex];
			var _velY = _particles[# BBMOD_EParticle.VelocityY, _particleIndex];
			var _velZ = _particles[# BBMOD_EParticle.VelocityZ, _particleIndex];
			var _speed = sqrt((_velX * _velX) + (_velY + _velY) + (_velZ * _velZ));
			var _factor = clamp((_speed - _min) / _div, 0.0, 1.0);
			_particles[# BBMOD_EParticle.ColorR, _particleIndex] = lerp(_fromR, _toR, _factor);
			_particles[# BBMOD_EParticle.ColorG, _particleIndex] = lerp(_fromG, _toG, _factor);
			_particles[# BBMOD_EParticle.ColorB, _particleIndex] = lerp(_fromB, _toB, _factor);
			_particles[# BBMOD_EParticle.ColorA, _particleIndex] = lerp(_fromA, _toA, _factor);
			++_particleIndex;
		}
	};
}
