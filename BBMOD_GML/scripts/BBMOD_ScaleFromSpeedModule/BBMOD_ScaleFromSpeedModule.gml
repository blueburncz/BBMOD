/// @func BBMOD_ScaleFromSpeedModule([_from[, _to[, _min[, _max]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that controls scale of particles based on
/// magnitude of their velocity vector.
///
/// @param {Struct.BBMOD_Vec3} [_from] The scale to blend from. Defaults to
/// `(1.0, 1.0, 1.0)`.
/// @param {Struct.BBMOD_Vec3} [_to] The scale to blend to. Defaults to
/// `(0.0, 0.0, 0.0)`.
/// @param {Real} [_min] If a particle's speed is less than this, then its
/// scale will be equal to `_from`. Defaults to 0.0.
/// @param {Real} [_max] If a particle's speed is greater than this, then its
/// scale will be equal to `_to`. Defaults to 1.0.
///
/// @see BBMOD_EParticle.ScaleX
/// @see BBMOD_EParticle.ScaleY
/// @see BBMOD_EParticle.ScaleZ
/// @see BBMOD_EParticle.VelocityX
/// @see BBMOD_EParticle.VelocityY
/// @see BBMOD_EParticle.VelocityZ
function BBMOD_ScaleFromSpeedModule(_from=new BBMOD_Vec3(1.0), _to=new BBMOD_Vec3(), _min=0.0, _max=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3} The scale to blend from. Default value is
	/// `(1.0, 1.0, 1.0)`.
	From = _from;

	/// @var {Struct.BBMOD_Vec3} The scale to blend to. Default value is
	/// `(0.0, 0.0, 0.0)`.
	To = _to;

	/// @var {Real} If a particle's speed is less than this, then its
	/// scale will be equal to {BBMOD_ScaleFromSpeedModule.From}.
	/// Default value is 0.0.
	Min = _min;

	/// @var {Real} If a particle's speed is greater than this, then its
	/// scale will be equal to {BBMOD_ScaleFromSpeedModule.To}.
	/// Default value is 1.0.
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
