/// @module Core

/// @func BBMOD_PunctualLight([_color[, _position[, _range]]])
///
/// @extends BBMOD_Light
///
/// @desc Base struct for punctual lights.
///
/// @param {Struct.BBMOD_Color} [_color] The light's color. Defaults
/// to {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Vec3} [_position] The light's position.
/// Defaults to `(0, 0, 0)`.
/// @param {Real} [_range] The light's range. Defaults to 1.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_count
/// @see bbmod_light_punctual_get
/// @see bbmod_light_punctual_remove
/// @see bbmod_light_punctual_remove_index
/// @see bbmod_light_punctual_clear
function BBMOD_PunctualLight(_color=BBMOD_C_WHITE, _position=undefined, _range=1.0)
	: BBMOD_Light() constructor
{
	/// @var {Struct.BBMOD_Color} The color of the light. Default value is
	/// {@link BBMOD_C_WHITE}.
	Color = _color;

	if (_position != undefined)
	{
		Position = _position;
	}

	/// @var {Real} The range of the light.
	Range = _range;

	__getZFar = __get_shadowmap_zfar;

	static __get_shadowmap_zfar = function ()
	{
		gml_pragma("forceinline");
		return Range;
	};
}

/// @func bbmod_light_punctual_add(_light)
///
/// @desc Adds a punctual light to the current scene.
///
/// @param {Struct.BBMOD_PunctualLight} _light The punctual light.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_count
/// @see bbmod_light_punctual_get
/// @see bbmod_light_punctual_remove
/// @see bbmod_light_punctual_remove_index
/// @see bbmod_light_punctual_clear
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.add_punctual_light} instead.
function bbmod_light_punctual_add(_light)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().add_punctual_light(_light);
}

/// @func bbmod_light_punctual_count()
///
/// @desc Retrieves number of punctual lights added to the current scene.
///
/// @return {Real} The number of punctual lights added to be sent to shaders.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_get
/// @see bbmod_light_punctual_remove
/// @see bbmod_light_punctual_remove_index
/// @see bbmod_light_punctual_clear
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.get_punctual_light_count} instead.
function bbmod_light_punctual_count()
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().get_punctual_light_count();
}

/// @func bbmod_light_punctual_get(_index)
///
/// @desc Retrieves a punctual light at given index from the current scene.
///
/// @param {Real} _index The index of the punctual light.
///
/// @return {Struct.BBMOD_PunctualLight} The punctual light.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_count
/// @see bbmod_light_punctual_remove
/// @see bbmod_light_punctual_remove_index
/// @see bbmod_light_punctual_clear
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.get_punctual_light} instead.
function bbmod_light_punctual_get(_index)
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().get_punctual_light(_index);
}

/// @func bbmod_light_punctual_remove(_light)
///
/// @desc Removes a punctual light from the current scene.
///
/// @param {Struct.BBMOD_PunctualLight} _light The punctual light to remove.
///
/// @return {Bool} Returns `true` if the punctual light was removed or `false` if
/// the light was not found.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_count
/// @see bbmod_light_punctual_get
/// @see bbmod_light_punctual_remove_index
/// @see bbmod_light_punctual_clear
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.remove_punctual_light} instead.
function bbmod_light_punctual_remove(_light)
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().remove_punctual_light(_light);
}

/// @func bbmod_light_punctual_remove_index(_index)
///
/// @desc Removes a punctual light at given index from the current scene.
///
/// @param {Real} _index The index to remove the punctual light at.
///
/// @return {Bool} Always returns `true`.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_count
/// @see bbmod_light_punctual_get
/// @see bbmod_light_punctual_remove
/// @see bbmod_light_punctual_clear
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.remove_punctual_light_index}
/// instead.
function bbmod_light_punctual_remove_index(_index)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().remove_punctual_light_index(_index);
	return true;
}

/// @func bbmod_light_punctual_clear()
///
/// @desc Removes all punctual lights added to the current scene.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_count
/// @see bbmod_light_punctual_get
/// @see bbmod_light_punctual_remove
/// @see bbmod_light_punctual_remove_index
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.clear_punctual_lights} instead.
function bbmod_light_punctual_clear()
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().clear_punctual_lights();
}
