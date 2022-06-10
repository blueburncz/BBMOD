/// @func BBMOD_SpeedKillModule([_min[, _max]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that kills all particles with magnitude of their
/// velocity vector below a minimum value or above a maximum value.
///
/// @param {Real/Undefined} [_min] The minimum speed the particle needs to have
/// or it is killed. Use `undefined` if you do not want to use a minimum value.
/// Defauts to `undefined`.
/// @param {Real/Undefined} [_max] The maximum speed the particle needs to have
/// or it is killed. Use `undefined` if you do not want to use a maximum value.
/// Defauts to `undefined`.
///
/// @see BBMOD_EParticle.VelocityX
/// @see BBMOD_EParticle.VelocityY
/// @see BBMOD_EParticle.VelocityZ
function BBMOD_SpeedKillModule(_min=undefined, _max=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real/Undefined} The minimum speed the particle needs to have or it
	/// is killed. Use `undefined` if you do not want to use a minimum value.
	/// Defaut value is `undefined`.
	Min = _min;

	/// @var {Real/Undefined} The maximum speed the particle needs to have or it
	/// is killed. Use `undefined` if you do not want to use a maximum value.
	/// Defaut value is `undefined`.
	Max = _max;

	static on_update = function (_emitter, _deltaTime) {
		var _min = Min;
		var _max = Max;
		if (_min == undefined && _max == undefined)
		{
			return;
		}
		var _particles = _emitter.Particles;
		var _particleIndex = 0;
		repeat (_emitter.ParticlesAlive)
		{
			var _velX = _particles[# BBMOD_EParticle.VelocityX, _particleIndex];
			var _velY = _particles[# BBMOD_EParticle.VelocityY, _particleIndex];
			var _velZ = _particles[# BBMOD_EParticle.VelocityZ, _particleIndex];
			var _speed = sqrt((_velX * _velX) + (_velY * _velY) + (_velZ * _velZ));
			if ((_min != undefined && _speed < _min)
				|| (_max != undefined && _speed > _max))
			{
				_particles[# BBMOD_EParticle.HealthLeft, _particleIndex] = 0;
			}
			++_particleIndex;
		}
	};
}
