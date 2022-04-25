/// @func BBMOD_MixInitialHealthModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_from]
/// @param {Real} [_to]
function BBMOD_MixInitialHealthModule(_from=1.0, _to=_from)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	From = _from;

	/// @var {Real}
	To = _to;

	static on_particle_start = function (_particle) {
		var _health = From.Mix(To, random(1.0));
		_particle.Health = _health;
		_particle.HealthLeft = _health;
	};
}
