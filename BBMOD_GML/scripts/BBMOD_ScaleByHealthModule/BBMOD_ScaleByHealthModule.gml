/// @func BBMOD_ScaleByHealthModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_from]
/// @param {Struct.BBMOD_Vec3/Undefined} [_to]
function BBMOD_ScaleByHealthModule(_from=undefined, _to=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	From = _from ?? new BBMOD_Vec3(1.0);

	/// @var {Struct.BBMOD_Vec3}
	To = _to ?? new BBMOD_Vec3();

	static on_particle_update = function (_particle, _deltaTime) {
		with (_particle)
		{
			Scale = other.To.Lerp(other.From, clamp(HealthLeft / Health, 0.0, 1.0));
		}
	};
}
