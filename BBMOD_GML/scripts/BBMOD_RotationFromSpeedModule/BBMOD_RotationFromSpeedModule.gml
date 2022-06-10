/// @func BBMOD_RotationFromSpeedModule([_from[, _to[, _min[, _max]]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that rotates particles based on magnitude of their
/// velocity vector.
///
/// @param {Struct.BBMOD_Quaternion} [_from]
/// @param {Struct.BBMOD_Quaternion} [_to]
/// @param {Real} [_min]
/// @param {Real} [_max]
///
/// @see BBMOD_EParticle.RotationX
/// @see BBMOD_EParticle.RotationY
/// @see BBMOD_EParticle.RotationZ
/// @see BBMOD_EParticle.RotationW
/// @see BBMOD_EParticle.VelocityX
/// @see BBMOD_EParticle.VelocityY
/// @see BBMOD_EParticle.VelocityZ
function BBMOD_RotationFromSpeedModule(_from=new BBMOD_Quaternion(), _to=_from.Clone(), _min=0.0, _max=1.0)
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
