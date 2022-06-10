/// @func BBMOD_AddHealthOverTimeModule([_change[, _period]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that adds health to particles over time.
///
/// @param {Real} [_change] How much health to add over specified period. Defaults
/// to -1.0.
/// @param {Real} [_period] The period (in seconds) over which `_change` of health
/// is added to particles. Defaults to 1.0.
///
/// @see BBMOD_EParticle.HealthLeft
function BBMOD_AddHealthOverTimeModule(_change=-1.0, _period=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real} How much health to add over
	/// {@link BBMOD_AddHealthOverTimeModule.Period}. Default value is -1.0.
	Change = _change;

	/// @var {Real} The period (in seconds) over which
	/// {@link BBMOD_AddHealthOverTimeModule.Change} of health
	/// is added to particles. Default value is 1.0.
	Period = _period;

	static on_update = function (_emitter, _deltaTime) {
		if (_emitter.ParticlesAlive > 0)
		{
			ds_grid_add_region(
				_emitter.Particles,
				BBMOD_EParticle.HealthLeft, 0,
				BBMOD_EParticle.HealthLeft, _emitter.ParticlesAlive - 1,
				Change * ((_deltaTime * 0.000001) / Period));
		}
	};
}
