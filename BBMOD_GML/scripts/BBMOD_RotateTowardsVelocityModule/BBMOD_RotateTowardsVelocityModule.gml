/// @func BBMOD_RotateTowardsVelocityModule([_forward[, _up]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_forward]
/// @param {Struct.BBMOD_Vec3/Undefined} [_up]
function BBMOD_RotateTowardsVelocityModule(_forward=undefined, _up=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Forward = _forward ?? BBMOD_VEC3_FORWARD;

	/// @var {Struct.BBMOD_Vec3}
	Up = _up ?? BBMOD_VEC3_UP;

	static on_update = function (_emitter, _deltaTime) {
		var _y2 = _emitter.ParticlesAlive - 1;
		if (_y2 >= 0)
		{
			// TODO: Implement BBMOD_RotateTowardsVelocityModule
		}
	};
}