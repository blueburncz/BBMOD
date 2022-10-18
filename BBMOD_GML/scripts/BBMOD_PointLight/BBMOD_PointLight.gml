/// @var {Array<Struct.BBMOD_PointLight>}
/// @private
global.__bbmodPointLights = [];

/// @func BBMOD_PointLight([_color[, _position[, _range]]])
///
/// @extends BBMOD_Light
///
/// @desc A point light.
///
/// @param {Struct.BBMOD_Color} [_color] The light's color. Defaults
/// to {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Vec3} [_position] The light's position.
/// Defaults to `(0, 0, 0)`.
/// @param {Real} [_range] The light's range. Defaults to 1.
function BBMOD_PointLight(_color=BBMOD_C_WHITE, _position=undefined, _range=1.0)
	: BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_Color} The color of the light. Default value is
	/// {@link BBMOD_C_WHITE}.
	Color = _color;

	if (_position != undefined)
	{
		Position = _position;
	}

	/// @var {Real} The range of the light.
	Range = _range;
}

/// @func bbmod_light_point_add(_light)
///
/// @desc Adds a point light to be sent to shaders.
///
/// @param {Struct.BBMOD_PointLight} _light The point light.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_count
/// @see bbmod_light_point_get
/// @see bbmod_light_point_remove
/// @see bbmod_light_point_remove_index
/// @see bbmod_light_point_clear
/// @see BBMOD_PointLight
function bbmod_light_point_add(_light)
{
	gml_pragma("forceinline");
	array_push(global.__bbmodPointLights, _light);
}

/// @func bbmod_light_point_count()
///
/// @desc Retrieves number of point lights added to be sent to shaders.
///
/// @return {Real} The number of point lights added to be sent to shaders.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_get
/// @see bbmod_light_point_remove
/// @see bbmod_light_point_remove_index
/// @see bbmod_light_point_clear
/// @see BBMOD_PointLight
function bbmod_light_point_count()
{
	gml_pragma("forceinline");
	return array_length(global.__bbmodPointLights);
}

/// @func bbmod_light_point_get(_index)
///
/// @desc Retrieves a point light at given index.
///
/// @param {Real} _index The index of the point light.
///
/// @return {Struct.BBMOD_PointLight} The point light.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_count
/// @see bbmod_light_point_remove
/// @see bbmod_light_point_remove_index
/// @see bbmod_light_point_clear
/// @see BBMOD_PointLight
function bbmod_light_point_get(_index)
{
	gml_pragma("forceinline");
	return global.__bbmodPointLights[_index];
}

/// @func bbmod_light_point_remove(_light)
///
/// @desc Removes a point light so it is not sent to shaders anymore.
///
/// @param {Struct.BBMOD_PointLight} _light The point light to remove.
///
/// @return {Bool} Returns `true` if the point light was removed or `false` if
/// the light was not found.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_count
/// @see bbmod_light_point_get
/// @see bbmod_light_point_remove_index
/// @see bbmod_light_point_clear
/// @see BBMOD_PointLight
function bbmod_light_point_remove(_light)
{
	gml_pragma("forceinline");
	var _pointLights = global.__bbmodPointLights;
	var i = 0;
	repeat (array_length(_pointLights))
	{
		if (_pointLights[i] == _light)
		{
			array_delete(_pointLights, i, 1);
			return true;
		}
		++i;
	}
	return false;
}

/// @func bbmod_light_point_remove_index(_index)
///
/// @desc Removes a point light so it is not sent to shaders anymore.
///
/// @param {Real} _index The index to remove the point light at.
///
/// @return {Bool} Always returns `true`.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_count
/// @see bbmod_light_point_get
/// @see bbmod_light_point_remove
/// @see bbmod_light_point_clear
/// @see BBMOD_PointLight
function bbmod_light_point_remove_index(_index)
{
	gml_pragma("forceinline");
	array_delete(global.__bbmodPointLights, _index, 1);
	return true;
}

/// @func bbmod_light_point_clear()
///
/// @desc Removes all point lights sent to shaders.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_count
/// @see bbmod_light_point_get
/// @see bbmod_light_point_remove
/// @see bbmod_light_point_remove_index
/// @see BBMOD_PointLight
function bbmod_light_point_clear(_index)
{
	gml_pragma("forceinline");
	global.__bbmodPointLights = [];
}
