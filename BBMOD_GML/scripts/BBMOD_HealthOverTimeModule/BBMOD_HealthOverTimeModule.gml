/// @func BBMOD_HealthOverTimeModule([_change[, _period]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_change]
/// @param {Real} [_period]
function BBMOD_HealthOverTimeModule(_change=-1.0, _period=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Change = _change;

	/// @var {Real}
	Period = _period;

	static on_particle_update = function (_particle, _deltaTime) {
		_particle.HealthLeft += Change * ((_deltaTime * 0.000001) / Period);
	};
}
