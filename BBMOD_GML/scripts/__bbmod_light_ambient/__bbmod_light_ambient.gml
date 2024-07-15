/// @module Core

/// @func bbmod_light_ambient_set_dir(_dir)
///
/// @desc Changes the direction towards the ambient light's upper hemisphere in
/// the current scene.
///
/// @param {Struct.BBMOD_Vec3} _dir The direction towards the upper hemisphere.
/// Should be normalized!
///
/// @see bbmod_light_ambient_get_dir
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.AmbientLightDirection} instead.
function bbmod_light_ambient_set_dir(_dir)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().AmbientLightDirection = _dir;
}

/// @func bbmod_light_ambient_get_dir()
///
/// @desc Retrieves the direction towards the ambient light's upper hemisphere
/// in the current scene.
///
/// @return {Struct.BBMOD_Vec3} The direction towards the upper hemisphere.
/// The default value is {@link BBMOD_VEC3_UP}.
///
/// @see bbmod_light_ambient_set_dir
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.AmbientLightDirection} instead.
function bbmod_light_ambient_get_dir()
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().AmbientLightDirection;
}

/// @func bbmod_light_ambient_set(_color)
///
/// @desc Changes color of the ambient light in the current scene.
///
/// @param {Struct.BBMOD_Color} _color The new color of the ambient light (both
/// upper and lower hemisphere).
///
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_get_down
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.AmbientLightColorUp} and
/// {@link BBMOD_Scene.AmbientLightColorDown} instead.
function bbmod_light_ambient_set(_color)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().AmbientLightColorUp = _color;
	bbmod_scene_get_current().AmbientLightColorDown = _color;
}

/// @func bbmod_light_ambient_get_up()
///
/// @desc Retrieves color of the upper hemisphere of the ambient light in the
/// current scene.
///
/// @return {Struct.BBMOD_Color} The color of the upper hemisphere of the
/// ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_get_down
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.AmbientLightColorUp} instead.
function bbmod_light_ambient_get_up()
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().AmbientLightColorUp;
}

/// @func bbmod_light_ambient_set_up(_color)
///
/// @desc Changes color of the upper hemisphere of the ambient light in the
/// current scene.
///
/// @param {Struct.BBMOD_Color} _color The new color of the upper hemisphere of
/// the ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_get_down
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.AmbientLightColorUp} instead.
function bbmod_light_ambient_set_up(_color)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().AmbientLightColorUp = _color;
}

/// @func bbmod_light_ambient_get_down()
///
/// @desc Retrieves color of the lower hemisphere of the ambient light in the
/// current scene.
///
/// @return {Struct.BBMOD_Color} The color of the lower hemisphere of the
/// ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.AmbientLightColorDown} instead.
function bbmod_light_ambient_get_down()
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().AmbientLightColorDown;
}

/// @func bbmod_light_ambient_set_down(_color)
///
/// @desc Changes color of the lower hemisphere of the ambient light in the
/// current scene.
///
/// @param {Struct.BBMOD_Color} _color The new color of the lower hemisphere of
/// the ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_get_down
/// @see BBMOD_Color
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.AmbientLightColorDown} instead.
function bbmod_light_ambient_set_down(_color)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().AmbientLightColorDown = _color;
}

/// @func bbmod_light_ambient_get_affect_lightmaps()
///
/// @desc Checks whether ambient light in the current scene affects materials
/// that use baked lightmaps.
///
/// @return {Bool} Returns `true` if ambient light affects materials that
/// use lightmaps.
///
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.AmbientLightAffectLightmaps} instead.
function bbmod_light_ambient_get_affect_lightmaps()
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().AmbientLightAffectLightmaps;
}

/// @func bbmod_light_ambient_set_affect_lightmaps(_enable)
///
/// @desc Changes whether ambient light in the current scene affects materials
/// that use baked lightmaps.
///
/// @param {Bool} _enable Use `true` to enable ambient light affecting materials
/// that use baked lightmaps.
///
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.AmbientLightAffectLightmaps} instead.
function bbmod_light_ambient_set_affect_lightmaps(_enable)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().AmbientLightAffectLightmaps = _enable;
}
