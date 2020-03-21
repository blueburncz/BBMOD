/// @fun b_bbmod_rotation_key_load(buffer)
/// @param {real} buffer
/// @return array
var _buffer = argument0;
var _key = array_create(B_EBBMODRotationKey.SIZE, 0);
_key[@ B_EBBMODRotationKey.Time] = buffer_read(_buffer, buffer_f64);
_key[@ B_EBBMODRotationKey.Rotation] = b_bbmod_load_quaternion(_buffer);
return _key;