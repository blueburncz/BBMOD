/// @func bbmod_get_animation_key_interpolation_factor(key, key_next, animation_time)
/// @desc Calculates interpolation factor between two animation keys at specified
/// animation time.
/// @param {array} key The first AnimationKey structure.
/// @param {array} key_next The second AnimationKey structure.
/// @param {real} animation_time The animation time.
/// @return {real} The calculated interpolation factor.
gml_pragma("forceinline");
var _key = argument0;
var _key_next = argument1;
var _animation_time = argument2;
var _delta_time = _key_next[BBMOD_EAnimationKey.Time] - _key[BBMOD_EAnimationKey.Time];
if (_delta_time == 0)
{
	return 0;
}
var _factor = (_animation_time - _key[BBMOD_EAnimationKey.Time]) / _delta_time;
return clamp(_factor, 0, 1);