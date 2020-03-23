/// @func b_bbmod_load_matrix(buffer)
/// @desc Loads a 4x4 row-major matrix from a buffer.
/// @param {real} buffer The buffer to load the matrix from.
/// @return {array} The loaded matrix.
var _buffer = argument0;
var _matrix = array_create(16, 0);
for (var i/*:int*/= 0; i < 16; ++i)
{
	_matrix[@ i] = buffer_read(_buffer, buffer_f32);
}
ce_matrix_transpose(_matrix);
return _matrix;