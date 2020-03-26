/// @fun bbmod_rotation_key_load(buffer)
/// @param {real} buffer
/// @return array
var _buffer = argument0;
var _key = array_create(BBMOD_ERotationKey.SIZE, 0);
_key[@ BBMOD_ERotationKey.Time] = buffer_read(_buffer, buffer_f64);
_key[@ BBMOD_ERotationKey.Rotation] = bbmod_load_quaternion(_buffer);
return _key;