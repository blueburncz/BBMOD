/// @func BBMOD_AddRotationOverTimeModule([_change[, _period]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that rotates particles over time.
///
/// @param {Struct.BBMOD_Quaternion} [_change]
/// @param {Real} [_period]
///
/// @see BBMOD_EParticle.RotationX
/// @see BBMOD_EParticle.RotationY
/// @see BBMOD_EParticle.RotationZ
/// @see BBMOD_EParticle.RotationW
function BBMOD_AddRotationOverTimeModule(_change=new BBMOD_Quaternion(), _period=1.0)
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
