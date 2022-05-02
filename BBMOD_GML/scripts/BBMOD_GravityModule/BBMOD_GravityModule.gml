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
		var _y2 = _emitter.ParticlesAlive - 1;
		if (_y2 >= 0)
		{
			var _particles = _emitter.Particles;
			var _gridCompute = _emitter.GridCompute;
			var _gravity = Gravity;

			ds_grid_set_region(
				_gridCompute,
				0, 0,
				0, _y2,
				_gravity.X);

			ds_grid_multiply_grid_region(
				_gridCompute,
				_particles,
				BBMOD_EParticle.Mass, 0,
				BBMOD_EParticle.Mass, _y2,
				0, 0);

			ds_grid_set_region(
				_gridCompute,
				1, 0,
				1, _y2,
				_gravity.Y);

			ds_grid_multiply_grid_region(
				_gridCompute,
				_particles,
				BBMOD_EParticle.Mass, 0,
				BBMOD_EParticle.Mass, _y2,
				1, 0);

			ds_grid_set_region(
				_gridCompute,
				2, 0,
				2, _y2,
				_gravity.Z);

			ds_grid_multiply_grid_region(
				_gridCompute,
				_particles,
				BBMOD_EParticle.Mass, 0,
				BBMOD_EParticle.Mass, _y2,
				2, 0);

			ds_grid_add_grid_region(
				_particles,
				_gridCompute,
				0, 0,
				2, _y2,
				BBMOD_EParticle.AccelerationX, 0);
		}
	};
}