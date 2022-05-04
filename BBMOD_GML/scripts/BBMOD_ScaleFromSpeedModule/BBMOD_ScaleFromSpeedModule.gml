/// @func BBMOD_ScaleFromSpeedModule([_from[, _to[, _min[, _max]]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_from]
/// @param {Struct.BBMOD_Vec3/Undefined} [_to]
/// @param {Real} [_min]
/// @param {Real} [_max]
function BBMOD_ScaleFromSpeedModule(_from=undefined, _to=undefined, _min=0.0, _max=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	From = _from ?? new BBMOD_Vec3(1.0);

	/// @var {Struct.BBMOD_Vec3}
	To = _to ?? new BBMOD_Vec3();

	/// @var {Real}
	Min = _min;

	/// @var {Real}
	Max = _max;

	static on_update = function (_emitter, _deltaTime) {
		var _particles = _emitter.Particles;
		var _from = From;
		var _fromX = _from.X;
		var _fromY = _from.Y;
		var _fromZ = _from.Z;
		var _to = To;
		var _toX = _to.X;
		var _toY = _to.Y;
		var _toZ = _to.Z;
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
			_particles[# BBMOD_EParticle.ScaleX, _particleIndex] = lerp(_fromX, _toX, _factor);
			_particles[# BBMOD_EParticle.ScaleY, _particleIndex] = lerp(_fromY, _toY, _factor);
			_particles[# BBMOD_EParticle.ScaleZ, _particleIndex] = lerp(_fromZ, _toZ, _factor);
			++_particleIndex;
		}
	};
}
