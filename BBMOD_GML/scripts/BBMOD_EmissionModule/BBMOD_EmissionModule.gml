/// @func BBMOD_EmissionModule([_interval])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_interval]
function BBMOD_EmissionModule(_interval=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Interval = _interval;

	/// @var {Real]
	/// @private
	Timer = 0.0;

	static on_update = function (_emitter, _deltaTime) {
		Timer += _deltaTime * 0.000001;
		if (Timer >= Interval)
		{
			_emitter.spawn_particle();
			Timer = 0.0;
		}
	};
}
