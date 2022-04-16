/// @func BBMOD_RandomColorModule([_color1[, _color2]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Color/Undefined} [_color1]
/// @param {Struct.BBMOD_Color/Undefined} [_color2]
function BBMOD_RandomColorModule(_color1=undefined, _color2=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Color}
	Color1 = _color1 ?? BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Color}
	Color2 = _color2 ?? Color1;

	static on_particle_start = function (_particle) {
		_particle.Color = Color1.Mix(Color2, random(1.0));
	};
}
