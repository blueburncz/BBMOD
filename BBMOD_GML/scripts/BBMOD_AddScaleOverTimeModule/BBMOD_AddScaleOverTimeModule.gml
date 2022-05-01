/// @func BBMOD_AddScaleOverTimeModule([_change[, _period]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_change]
/// @param {Real} [_period]
function BBMOD_AddHealthOverTimeModule(_change=undefined, _period=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Change = _change;

	/// @var {Real}
	Period = _period;

	static on_update = function (_emitter, _deltaTime) {
		if (_emitter.ParticlesAlive > 0)
		{
			var _factor = (_deltaTime * 0.000001) / Period;

			ds_grid_add_region(
				_emitter.Particles,
				BBMOD_EParticle.ScaleX, 0,
				BBMOD_EParticle.ScaleX, _emitter.ParticlesAlive - 1,
				Change.X * _factor);

			ds_grid_add_region(
				_emitter.Particles,
				BBMOD_EParticle.ScaleY, 0,
				BBMOD_EParticle.ScaleY, _emitter.ParticlesAlive - 1,
				Change.Y * _factor);

			ds_grid_add_region(
				_emitter.Particles,
				BBMOD_EParticle.ScaleZ, 0,
				BBMOD_EParticle.ScaleZ, _emitter.ParticlesAlive - 1,
				Change.Z * _factor);
		}
	};
}
