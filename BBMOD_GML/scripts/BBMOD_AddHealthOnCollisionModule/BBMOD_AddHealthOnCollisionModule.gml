/// @func BBMOD_AddHealthOnCollisionModule([_change])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that adds health to particles when they collide.
///
/// @param {Real} [_change] The value to add to particles' health. Defaults
/// to -1.0.
///
/// @see BBMOD_EParticle.HealthLeft
/// @see BBMOD_EParticle.HasCollided
function BBMOD_AddHealthOnCollisionModule(_change=-1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real} The value to add to particles' health when they collide.
	/// Default value is -1.0.
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
