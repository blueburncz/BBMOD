/// @func bbmod_get_animation_time(animation, time_in_seconds)
/// @desc Calculates animation time from current time in seconds.
/// @param {array} animation The Animation structure.
/// @param {real} time_in_seconds The current time in seconds.
/// @return {real} The animation time.
gml_pragma("forceinline");
var _animation = argument0;
var _animation_duration = _animation[@ BBMOD_EAnimation.Duration];
var _animation_tics_per_sec = _animation[@ BBMOD_EAnimation.TicsPerSecond];
var _time_in_tics = argument1 * _animation_tics_per_sec;
return (_time_in_tics mod _animation_duration);