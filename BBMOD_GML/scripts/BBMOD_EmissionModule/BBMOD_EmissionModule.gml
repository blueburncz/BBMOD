/// @func BBMOD_EmissionModule([_interval[, _count]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_interval]
/// @param {Real} [_count]
function BBMOD_EmissionModule(_interval=1.0, _count=1)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Interval = _interval;

	/// @var {Real}
	Count = _count;

	/// @var {Real]
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
