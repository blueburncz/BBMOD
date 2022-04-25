/// @func BBMOD_InitialHealthModule([_health])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_health]
function BBMOD_InitialHealthModule(_health=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Health = _health;

	static on_particle_start = function (_particle) {
		_particle.Health = Health;
		_particle.HealthLeft = Health;
	};
}
