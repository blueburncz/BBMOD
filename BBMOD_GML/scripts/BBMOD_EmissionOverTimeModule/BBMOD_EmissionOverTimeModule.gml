/// @func BBMOD_EmissionOverTimeModule([_interval[, _count]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that emits particles over time.
///
/// @param {Real} [_interval] Number of seconds to wait before spawning
/// next particles. Defaults to 1.0.
/// @param {Real} [_count] Number of particles to spawn each time. Defaults
/// to 1.
function BBMOD_EmissionOverTimeModule(_interval=1.0, _count=1)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real} Number of seconds to wait before spawning
	/// next particles. Default value is 1.0.
	Interval = _interval;

	/// @var {Real} Number of particles to spawn each time. Default
	/// value is 1.
	Count = _count;

	/// @var {Real}
	/// @private
	Timer = 0.0;

	static on_update = function (_emitter, _deltaTime) {
		Timer += _deltaTime * 0.000001;
		if (Timer >= Interval)
		{
			repeat (Count)
			{
				_emitter.spawn_particle();
			}
			Timer = 0.0;
		}
	};
}
