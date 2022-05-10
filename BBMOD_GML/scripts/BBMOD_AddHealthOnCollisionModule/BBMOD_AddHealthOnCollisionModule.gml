/// @func BBMOD_AddHealthOnCollisionModule([_change])
/// @extends BBMOD_ParticleModule
/// @param {Real} [_change]
function BBMOD_AddHealthOnCollisionModule(_change=-1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Change = _change;

	static on_update = function (_emitter, _deltaTime) {
		var _y2 = _emitter.ParticlesAlive - 1;
		if (_y2 >= 0)
		{
			var _particles = _emitter.Particles;
			var _gridCompute = _emitter.GridCompute;

			ds_grid_set_region(
				_gridCompute,
				0, 0,
				0, _y2,
				Change);

			ds_grid_multiply_grid_region(
				_gridCompute,
				_particles,
				BBMOD_EParticle.HasCollided, 0,
				BBMOD_EParticle.HasCollided, _y2,
				0, 0);

			ds_grid_add_grid_region(
				_particles,
				_gridCompute,
				0, 0,
				0, _y2,
				BBMOD_EParticle.HealthLeft, 0);
		}
	};
}