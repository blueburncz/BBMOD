/// @func bbmod_get_interpolated_position_key(positions, time[, index])
/// @desc Creates a new PositionKey struct by interpolating two closest ones
/// for specified animation time.
/// @param {array} positions An array of PositionKey structs.
/// @param {real} time The current animation time.
/// @param {real} index An index where to start searching for two closest
/// position keys for specified time. Defaults to 0.
/// @return {array} The interpolated PositionKey.
var _positions = argument[0];
var _time = argument[1];
var _index = (argument_count > 2) ? argument[2] : 0;
var k = bbmod_find_animation_key(_positions, _time, _index);
var _position_key = bbmod_get_animation_key(_positions, k);
var _position_key_next = bbmod_get_animation_key(_positions, k + 1);
var _factor = bbmod_get_animation_key_interpolation_factor(
	_position_key, _position_key_next, _time);
return bbmod_position_key_interpolate(
	_position_key, _position_key_next, _factor);