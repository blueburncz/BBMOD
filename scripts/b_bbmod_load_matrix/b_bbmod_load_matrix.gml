/// @func b_bbmod_load_matrix(buffer)
/// @param {real} buffer
/// @return {array}
var _buffer = argument0;
var _matrix = array_create(16, 0);
for (var i = 0; i < 16; ++i)
{
	_matrix[@ i] = buffer_read(_buffer, buffer_f32);
}
ce_matrix_transpose(_matrix);
return _matrix;