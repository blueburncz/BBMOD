/// @func b_bbmod_get_animation_key_interpolation_factor(key, key_next, animation_time)
/// @param {array} key
/// @param {array} key_next
/// @param {real} animation_time
/// @return {real}
gml_pragma("forceinline");
var _key = argument0;
var _key_next = argument1;
var _animation_time = argument2;
var _delta_time = _key_next[B_EBBMODAnimationKey.Time] - _key[B_EBBMODAnimationKey.Time];
if (_delta_time == 0)
{
	return 0;
}
var _factor = (_animation_time - _key[B_EBBMODAnimationKey.Time]) / _delta_time;
return clamp(_factor, 0, 1);
