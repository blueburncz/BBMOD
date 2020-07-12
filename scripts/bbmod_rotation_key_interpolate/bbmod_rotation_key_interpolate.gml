/// @func bbmod_rotation_key_interpolate(rk1, rk2, factor)
/// @desc Interpolates between two RotationKey structures.
/// @param {array} rk1 The first RotationKey.
/// @param {array} rk2 The second RotationKey.
/// @param {real} factor The interpolation factor. Should be a value in range 0..1.
/// @return {array} A new RotationKey sructure with the interpolated animation time
/// and position.
var _rk1 = argument0;
var _rk2 = argument1;
var _factor = argument2;
var _key = array_create(BBMOD_EPositionKey.SIZE, 0);
_key[@ BBMOD_ERotationKey.Time] = lerp(
	_rk1[BBMOD_ERotationKey.Time],
	_rk2[BBMOD_ERotationKey.Time],
	_factor);
var _rotation = ce_quaternion_clone(_rk1[BBMOD_ERotationKey.Rotation]);
ce_quaternion_slerp(_rotation, _rk2[BBMOD_ERotationKey.Rotation], _factor);
_key[@ BBMOD_ERotationKey.Rotation] = _rotation;
return _key;