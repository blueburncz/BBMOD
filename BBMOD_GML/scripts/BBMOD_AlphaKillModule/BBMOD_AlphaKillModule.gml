/// @func BBMOD_AlphaKillModule([_min[, _max]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that kills all particles that have alpha less than
/// a minimum value or greater than a maximum value.
///
/// @param {Real/Undefined} [_min] The minimum alpha the particle needs to have
/// or it is killed. Use `undefined` if you do not want to use a minimum value.
/// Defaults to `undefined`.
/// @param {Real/Undefined} [_max] The maximum alpha the particle needs to have
/// or it is killed. Use `undefined` if you do not want to use a maximum value.
/// Defaults to `undefined`.
///
/// @see BBMOD_EParticle.ColorA
function BBMOD_AlphaKillModule(_min=undefined, _max=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real/Undefined} The minimum alpha the particle needs to have
	/// or it is killed. Use `undefined` if you do not want to use a minimum
	/// value. Default value is `undefined`.
	Min = _min;

	/// @var {Real/Undefined} The maximum alpha the particle needs to have
	/// or it is killed. Use `undefined` if you do not want to use a maximum
	/// value. Default value is `undefined`.
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
			var _alpha = _particles[# BBMOD_EParticle.ColorA, _particleIndex];
			if ((_min != undefined && _alpha < _min)
				|| (_max != undefined && _alpha > _max))
			{
				_particles[# BBMOD_EParticle.HealthLeft, _particleIndex] = 0;
			}
			++_particleIndex;
		}
	};
}
