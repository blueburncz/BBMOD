/// @func BBMOD_ColorFromHealthModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Color/Undefined} [_from]
/// @param {Struct.BBMOD_Color/Undefined} [_to]
function BBMOD_ColorFromHealthModule(_from=undefined, _to=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Color}
	From = _from ?? BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Color}
	To = _to ?? From;

	static on_particle_update = function (_particle, _deltaTime) {
		with (_particle)
		{
			Color = other.To.Lerp(other.From, clamp(HealthLeft / Health, 0.0, 1.0));
		}
	};
}
