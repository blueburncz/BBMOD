/// @func BBMOD_GravityModule([_gravity])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_gravity]
function BBMOD_GravityModule(_gravity=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Gravity = _gravity ?? BBMOD_VEC3_UP.Scale(-1.0);

	static on_update = function (_emitter, _deltaTime) {
		var _particles = _emitter.Particles;
		var _y2 = _emitter.ParticlesAlive - 1;
		var _gravity = Gravity;

		ds_grid_add_region(
			_particles,
			BBMOD_EParticle.AccelerationX, 0,
			BBMOD_EParticle.AccelerationX, _y2,
			_gravity.X);

		ds_grid_add_region(
			_particles,
			BBMOD_EParticle.AccelerationY, 0,
			BBMOD_EParticle.AccelerationY, _y2,
			_gravity.Y);

		ds_grid_add_region(
			_particles,
			BBMOD_EParticle.AccelerationZ, 0,
			BBMOD_EParticle.AccelerationZ, _y2,
			_gravity.Z);
	};
}