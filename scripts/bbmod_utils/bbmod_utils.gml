/// @func bbmod_load_matrix(_buffer)
/// @desc Loads a 4x4 row-major matrix from a buffer.
/// @param {buffer} _buffer The buffer to load the matrix from.
/// @return {real[]} The loaded matrix.
/// @private
function bbmod_load_matrix(_buffer)
{
	var _matrix = array_create(16, 0);
	for (var i = 0; i < 16; ++i)
	{
		_matrix[@ i] = buffer_read(_buffer, buffer_f32);
	}
	return _matrix;
}

/// @func bbmod_load_quaternion(_buffer)
/// @desc Loads a quaternion from a buffer.
/// @param {buffer} _buffer The buffer to load a quaternion from.
/// @return {real[]} The loaded quaternion.
/// @private
function bbmod_load_quaternion(_buffer)
{
	var _quaternion = array_create(4, 0);
	_quaternion[@ 0] = buffer_read(_buffer, buffer_f32);
	_quaternion[@ 1] = buffer_read(_buffer, buffer_f32);
	_quaternion[@ 2] = buffer_read(_buffer, buffer_f32);
	_quaternion[@ 3] = buffer_read(_buffer, buffer_f32);
	return _quaternion;
}

/// @func bbmod_load_vec3(_buffer)
/// @desc Loads a 3D vector from a buffer.
/// @param {buffer} _buffer The buffer to load the vector from.
/// @return {real[]} The loaded vector.
/// @private
function bbmod_load_vec3(_buffer)
{
	var _vec3 = array_create(3, 0);
	_vec3[@ 0] = buffer_read(_buffer, buffer_f32);
	_vec3[@ 1] = buffer_read(_buffer, buffer_f32);
	_vec3[@ 2] = buffer_read(_buffer, buffer_f32);
	return _vec3;
}