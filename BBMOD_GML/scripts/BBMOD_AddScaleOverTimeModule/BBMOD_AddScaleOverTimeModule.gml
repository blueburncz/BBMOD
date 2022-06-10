/// @func BBMOD_AddScaleOverTimeModule([_change[, _period]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that scales particle over time.
///
/// @param {Struct.BBMOD_Vec3} [_change] The change of particle scale over
/// specified period. Defaults to `(1.0, 1.0, 1.0)`.
/// @param {Real} [_period] The period (in seconds) over which `_change` of scale
/// is added to particles. Defaults to 1.0.
///
/// @see BBMOD_EParticle.ScaleX
/// @see BBMOD_EParticle.ScaleY
/// @see BBMOD_EParticle.ScaleZ
function BBMOD_AddScaleOverTimeModule(_change=new BBMOD_Vec3(1.0), _period=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3} The change of particle scale over
	/// {@link BBMOD_AddScaleOverTimeModule.Period}. Default value is
	/// `(1.0, 1.0, 1.0)`.
	Change = _change;

	/// @var {Real} The period (in seconds) over which
	/// {@link BBMOD_AddScaleOverTimeModule.Change} of scale is added to
	/// particles. Default value is 1.0.
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
