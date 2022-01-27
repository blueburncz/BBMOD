/// @func BBMOD_PointLight([_color[, _position[, _range]]])
/// @extends BBMOD_Light
/// @desc A point light.
/// @param {BBMOD_Color/undefined} [_color] The light's color. Defaults to
/// {@link BBMOD_C_WHITE}.
/// @param {BBMOD_Vec3/undefined} [_position] The light's position. Defaults to
/// `[0, 0, 0]`.
/// @param {real} [_range] The light's range. Defaults to 1.
function BBMOD_PointLight(_color=undefined, _position=undefined, _range=1.0)
	: BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {BBMOD_Color} The color of the light. Defaults to white.
	Color = _color ?? BBMOD_C_WHITE;

	if (_position != undefined)
	{
		Position = _position;
	}

	/// @var {real} The range of the light.
	Range = _range;
}