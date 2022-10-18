/// @func BBMOD_SpotLight([_color[, _position[, _direction[, _range[, _angleInner[, _angleOuter]]]]]])
///
/// @extends BBMOD_Light
///
/// @desc A spot light.
///
/// @param {Struct.BBMOD_Color} [_color] The light's color. Defaults to
/// {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Vec3} [_position] The light's position. Defaults to
/// `(0, 0, 0)` if `undefined`.
/// @param {Struct.BBMOD_Vec3} [_direction] The light's direction. Defaults to
/// {@link BBMOD_VEC3_FORWARD} if `undefined`.
/// @param {Real} [_range] The light's range. Defaults to 1.
/// @param {Real} [_angleInner] The inner cone angle in degrees. Defaults to 25.
/// @param {Real} [_angleOuter] The outer cone angle in degrees. Defaults to 30.
function BBMOD_SpotLight(
	_color=BBMOD_C_WHITE,
	_position=undefined,
	_direction=undefined,
	_range=1.0,
	_angleInner=25,
	_angleOuter=30
) : BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_Color} The color of the light. Defaul value is
	/// {@link BBMOD_C_WHITE}.
	Color = _color;

	if (_position != undefined)
	{
		Position = _position;
	}

	/// @var {Struct.BBMOD_Vec3} The direction of the light. The default value is
	/// `(1, 0, 0)`.
	Direction = _direction ?? BBMOD_VEC3_FORWARD;

	/// @var {Real} The range of the light.
	Range = _range;

	/// @var {Real} The inner cone angle in degrees. Default value is 25.
	AngleInner = _angleInner;

	/// @var {Real} The inner cone angle in degrees. Default value is 30.
	AngleOuter = _angleOuter;
}
