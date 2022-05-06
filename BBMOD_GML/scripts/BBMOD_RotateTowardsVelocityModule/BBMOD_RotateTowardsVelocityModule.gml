function BBMOD_RotateTowardsVelocityModule(_forward=undefined, _up=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Forward = _forward;

	/// @var {Struct.BBMOD_Vec3}
	Up = _up;

	static on_update = function (_emitter, _deltaTime) {
		var _y2 = _emitter.ParticlesAlive - 1;
		if (_y2 >= 0)
		{
			// TODO: Implement BBMOD_RotateTowardsVelocityModule
		}
	};
}