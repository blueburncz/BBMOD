/// @func bbmod_load_vec3(buffer)
/// @desc Loads a 3D vector from a buffer.
/// @param {real} buffer The buffer to load the vector from.
/// @return {array} The loaded vector.
var _buffer = argument0;
var _vec3 = array_create(3, 0);
_vec3[@ 0] = buffer_read(_buffer, buffer_f32);
_vec3[@ 1] = buffer_read(_buffer, buffer_f32);
_vec3[@ 2] = buffer_read(_buffer, buffer_f32);
return _vec3;