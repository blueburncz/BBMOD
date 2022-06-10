/// @func BBMOD_RotateTowardsVelocityModule([_forward[, _up]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that rotates particles towards their velocity.
///
/// @param {Struct.BBMOD_Vec3} [_forward] The forward vector. Defaults to
/// {@link BBMOD_VEC3_FORWARD}.
/// @param {Struct.BBMOD_Vec3} [_up] The up vector. Defaults to {@link BBMOD_VEC3_UP}.
///
/// @see BBMOD_EParticle.RotationX
/// @see BBMOD_EParticle.RotationY
/// @see BBMOD_EParticle.RotationZ
/// @see BBMOD_EParticle.RotationW
/// @see BBMOD_EParticle.VelocityX
/// @see BBMOD_EParticle.VelocityY
/// @see BBMOD_EParticle.VelocityZ
function BBMOD_RotateTowardsVelocityModule(_forward=BBMOD_VEC3_FORWARD, _up=BBMOD_VEC3_UP)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3} The forward vector. Default value is
	/// {@link BBMOD_VEC3_FORWARD}.
	Forward = _forward; 

	/// @var {Struct.BBMOD_Vec3} The up vector. Default value is
	/// {@link BBMOD_VEC3_UP}.
	Up = _up;

	static on_update = function (_emitter, _deltaTime) {
		var _y2 = _emitter.ParticlesAlive - 1;
		if (_y2 >= 0)
		{
			// TODO: Implement BBMOD_RotateTowardsVelocityModule
		}
	};
}
