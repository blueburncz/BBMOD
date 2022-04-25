/// @func BBMOD_InitialColorModule([_color])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Color/Undefined} [_color]
function BBMOD_InitialColorModule(_color)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Color}
	Color = _color ?? BBMOD_C_WHITE;

	static on_particle_start = function (_particle) {
		_particle.Color = Color.Clone();
	};
}
