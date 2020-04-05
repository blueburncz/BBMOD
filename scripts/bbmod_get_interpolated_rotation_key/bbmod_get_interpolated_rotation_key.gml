/// @func bbmod_get_interpolated_rotation_key(rotations, time[, index])
/// @desc Creates a new RotationKey struct by interpolating two closest ones
/// for specified animation time.
/// @param {array} rotations An array of RotationKey structs.
/// @param {real} time The current animation time.
/// @param {real} index An index where to start searching for two closest
/// rotation keys for specified time. Defaults to 0.
/// @return {array} The interpolated RotationKey.
var _rotations = argument[0];
var _time = argument[1];
var _index = (argument_count > 2) ? argument[2] : 0;
var k = bbmod_find_animation_key(_rotations, _time, _index);
var _rotation_key = bbmod_get_animation_key(_rotations, k);
var _rotation_key_next = bbmod_get_animation_key(_rotations, k + 1);
var _factor = bbmod_get_animation_key_interpolation_factor(
	_rotation_key, _rotation_key_next, _time);
return bbmod_rotation_key_interpolate(
	_rotation_key, _rotation_key_next, _factor);