/// @func b_bbmod_load_quaternion(buffer)
/// @param {real} buffer
/// @return {array}
var _buffer = argument0;
var _quaternion = array_create(4, 0);
_quaternion[@ 0] = buffer_read(_buffer, buffer_f32);
_quaternion[@ 1] = buffer_read(_buffer, buffer_f32);
_quaternion[@ 2] = buffer_read(_buffer, buffer_f32);
_quaternion[@ 3] = buffer_read(_buffer, buffer_f32);
return _quaternion;