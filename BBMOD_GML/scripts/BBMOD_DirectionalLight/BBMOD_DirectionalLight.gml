/// @var {Struct.BBMOD_DirectionalLight}
/// @private
global.__bbmodDirectionalLight = undefined;

/// @func BBMOD_DirectionalLight([_color[, _direction]])
///
/// @extends BBMOD_Light
///
/// @desc A directional light.
///
/// @param {Struct.BBMOD_Color} [_color] The light's color. Defaults to
/// {@link BBMOD_C_WHITE} if `undefined`.
/// @param {Struct.BBMOD_Vec3} [_direction] The light's direction. Defaults to
/// `(-1, 0, -1)` if `undefined`.
function BBMOD_DirectionalLight(_color=undefined, _direction=undefined)
	: BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_Color} The color of the light. Defaul value is
	/// {@link BBMOD_C_WHITE}.
	Color = _color ?? BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Vec3} The direction of the light. Default value is
	/// `(-1, 0, -1)`.
	Direction = _direction ?? new BBMOD_Vec3(-1.0, 0.0, -1.0).Normalize();
}

/// @func bbmod_light_directional_get()
///
/// @desc Retrieves the directional light passed to shaders.
///
/// @return {Struct.BBMOD_DirectionalLight} The directional light or `undefined`.
///
/// @see bbmod_light_directional_set
/// @see BBMOD_DirectionalLight
function bbmod_light_directional_get()
{
	gml_pragma("forceinline");
	return global.__bbmodDirectionalLight;
}

/// @func bbmod_light_directional_set(_light)
///
/// @desc Defines the directional light passed to shaders.
///
/// @param {Struct.BBMOD_DirectionalLight} _light The new directional light or
/// `undefined`.
///
/// @see bbmod_light_directional_get
/// @see BBMOD_DirectionalLight
function bbmod_light_directional_set(_light)
{
	gml_pragma("forceinline");
	global.__bbmodDirectionalLight = _light;
}
