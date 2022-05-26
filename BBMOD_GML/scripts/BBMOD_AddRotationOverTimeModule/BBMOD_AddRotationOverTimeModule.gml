/// @func BBMOD_AddRotationOverTimeModule([_change[, _period]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Quaternion/Undefined} [_change]
/// @param {Real} [_period]
function BBMOD_AddRotationOverTimeModule(_change=undefined, _period=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Quaternion}
	Change = _change;

	/// @var {Real}
	Period = _period;

	static on_update = function (_emitter, _deltaTime) {
		var _y2 = _emitter.ParticlesAlive - 1;
		if (_y2 >= 0)
		{
			// TODO: Implement BBMOD_AddRotationOverTimeModule
		}
	};
}