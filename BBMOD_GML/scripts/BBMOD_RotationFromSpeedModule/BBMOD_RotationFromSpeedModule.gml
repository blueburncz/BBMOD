/// @func BBMOD_RotationFromSpeedModule([_from[, _to[, _min[, _max]]]])
/// @param {Struct.BBMOD_Quaternion/Undefined} [_from]
/// @param {Struct.BBMOD_Quaternion/Undefined} [_to]
/// @param {Real} [_min]
/// @param {Real} [_max]
function BBMOD_RotationFromSpeedModule(_from=undefined, _to=undefined, _min=0.0, _max=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Quaternion}
	From = _from;

	/// @var {Struct.BBMOD_Quaternion}
	To = _to;

	/// @var {Real}
	Min = _min;

	/// @var {Real}
	Max = _max;

	static on_update = function (_emitter, _deltaTime) {
		var _y2 = _emitter.ParticlesAlive - 1;
		if (_y2 >= 0)
		{
			// TODO: Implement BBMOD_RotationFromSpeedModule
		}
	};
}