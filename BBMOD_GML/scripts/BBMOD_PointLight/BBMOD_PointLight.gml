/// @func BBMOD_PointLight([_color[, _position[, _range]]])
/// @extends BBMOD_Light
/// @desc A point light.
/// @param {Struct.BBMOD_Color} [_color] The light's color.
/// @param {Struct.BBMOD_Vec3} [_position] The light's position.
/// @param {Real} [_range] The light's range. Defaults to 1.
function BBMOD_PointLight(_color=undefined, _position=undefined, _range=1.0)
	: BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_Color} The color of the light. Defaults to white.
	Color = _color ?? BBMOD_C_WHITE;

	if (_position != undefined)
	{
		Position = _position;
	}

	/// @var {Real} The range of the light.
	Range = _range;
}