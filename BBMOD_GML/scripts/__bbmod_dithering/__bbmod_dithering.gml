/// @module Core

/// @macro {String} Name of an optional per-instance multiplier field used by
/// {@link BBMOD_DynamicBatch.default_fn}.
#macro BBMOD_DITHER_VALUE "bbmodDitherValue"

/// @var {Bool}
/// @private
global.__bbmodDitherEnabled = false;

/// @var {Real}
/// @private
global.__bbmodDitherValue = 1.0;

/// @func bbmod_dither_set_enabled(_enable)
///
/// @desc Enables or disables distance dithering globally.
///
/// @param {Bool} _enable Use `true` to enable distance dithering.
function bbmod_dither_set_enabled(_enable)
{
	gml_pragma("forceinline");
	global.__bbmodDitherEnabled = _enable;
	bbmod_shader_set_global_f(BBMOD_U_DITHER_ENABLE, _enable ? 1.0 : 0.0);
}

/// @func bbmod_dither_get_enabled()
///
/// @desc Retrieves whether global distance dithering is enabled.
///
/// @return {Bool} Returns `true` when enabled.
function bbmod_dither_get_enabled()
{
	gml_pragma("forceinline");
	return global.__bbmodDitherEnabled;
}

/// @func bbmod_dither_set_value(_value)
///
/// @desc Sets global distance-dither value.
///
/// @param {Real} _value Value in range 0..1.
function bbmod_dither_set_value(_value)
{
	gml_pragma("forceinline");
	var _clamped = clamp(_value, 0.0, 1.0);
	global.__bbmodDitherValue = _clamped;
	bbmod_shader_set_global_f(BBMOD_U_DITHER_FADE, _clamped);
}

/// @func bbmod_dither_get_value()
///
/// @desc Retrieves global distance-dither value.
///
/// @return {Real} Value in range 0..1.
function bbmod_dither_get_value()
{
	gml_pragma("forceinline");
	return global.__bbmodDitherValue;
}
