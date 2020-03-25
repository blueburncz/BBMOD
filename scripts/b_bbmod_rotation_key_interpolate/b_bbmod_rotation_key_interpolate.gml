/// @func b_bbmod_rotation_key_interpolate(rk1, rk2, factor)
/// @desc Interpolates between two rotation keys.
/// @param {array} rk1 The first rotation key.
/// @param {array} rk2 The second rotation key.
/// @param {real} factor The interpolation factor. Should be a value in range 0..1.
/// @return {array} A new key with the interpolated animation time and position.
var _rk1 = argument0;
var _rk2 = argument1;
var _factor = argument2;
var _key = array_create(B_EBBMODPositionKey.SIZE, 0);
_key[@ B_EBBMODRotationKey.Time] = lerp(
	_rk1[B_EBBMODRotationKey.Time],
	_rk2[B_EBBMODRotationKey.Time],
	_factor);
var _rotation = ce_quaternion_clone(_rk1[B_EBBMODRotationKey.Rotation]);
ce_quaternion_slerp(_rotation, _rk2[B_EBBMODRotationKey.Rotation], _factor);
_key[@ B_EBBMODRotationKey.Rotation] = _rotation;
return _key;