/// @module Core

/// @func bbmod_fog_set(_color, _intensity, _start, _end)
///
/// @desc Changes fog settings in the current scene.
///
/// @param {Struct.BBMOD_Color} _color The color of the fog. The default fog
/// color is white.
/// @param {Real} _intensity The intensity of the fog. Use values in range 0..1.
/// The default fog intensity is 0 (no fog).
/// @param {Real} _start The distance from the camera where the fog starts at.
/// The default fog start is 0.
/// @param {Real} _end The distance from the camera where the fog has the
/// maximum intensity. The default fog end is 1.
///
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.FogColor},
/// {@link BBMOD_Scene.FogIntensity}, {@link BBMOD_Scene.FogStart} and
/// {@link BBMOD_Scene.FogEnd} instead.
function bbmod_fog_set(_color, _intensity, _start, _end)
{
	gml_pragma("forceinline");
	with (bbmod_scene_get_current())
	{
		FogColor = _color;
		FogIntensity = _intensity;
		FogStart = _start;
		FogEnd = _end;
	}
}

/// @func bbmod_fog_get_color()
///
/// @desc Retrieves the color of the fog in the current scene.
///
/// @return {Struct.BBMOD_Color} The color of the fog.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.FogColor} instead.
function bbmod_fog_get_color()
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().FogColor;
}

/// @func bbmod_fog_set_color(_color)
///
/// @desc Changes the color of the fog in the current scene.
///
/// @param {Struct.BBMOD_Color} _color The new fog color. The default fog color
/// is white.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.FogColor} instead.
function bbmod_fog_set_color(_color)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().FogColor = _color;
}

/// @func bbmod_fog_get_intensity()
///
/// @desc Retrieves the fog intensity in the current scene.
///
/// @return {Real} The fog intensity.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.FogIntensity} instead.
function bbmod_fog_get_intensity()
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().FogIntensity;
}

/// @func bbmod_fog_set_intensity(_intensity)
///
/// @desc Changes the fog intensity in the current scene.
///
/// @param {Real} _intensity The new fog intensity. The default intensity of the
/// fog is 0 (no fog).
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.FogIntensity} instead.
function bbmod_fog_set_intensity(_intensity)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().FogIntensity = _intensity;
}

/// @func bbmod_fog_get_start()
///
/// @desc Retrieves the distance where the fog starts at in the current scene.
///
/// @return {Real} The distance where the fog starts at.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.FogStart} instead.
function bbmod_fog_get_start()
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().FogStart;
}

/// @func bbmod_fog_set_start(_start)
///
/// @desc Changes distance where the fog starts at in the current scene.
///
/// @param {Real} _start The new distance where the fog starts at. The default
/// value is 0.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.FogStart} instead.
function bbmod_fog_set_start(_start)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().FogStart = _start;
}

/// @func bbmod_fog_get_end()
///
/// @desc Retrieves the distance at which the fog in the current scene reaches
/// its maximum intensity.
///
/// @return {Real} The distance where the fog has the maximum intensity.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_set_end
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.FogEnd} instead.
function bbmod_fog_get_end()
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().FogEnd;
}

/// @func bbmod_fog_set_end(_end)
///
/// @desc Changes the distance at which the fog in the current scene reaches
/// its maximum intensity.
///
/// @param {Real} _end The distance where the fog has the maximum intensity.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_scene_get_current
///
/// @deprecated Please use {@link BBMOD_Scene.FogEnd} instead.
function bbmod_fog_set_end(_end)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().FogEnd = _end;
}
