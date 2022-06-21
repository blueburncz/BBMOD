/// @func bbmod_array_from_buffer(_buffer, _type, _size)
///
/// @desc Creates an array with values from a buffer.
///
/// @param {Id.Buffer} _buffer The buffer to load the data from.
/// @param {Constant.BufferDataType} _type The value type.
/// @param {Real} _size The number of values to load.
///
/// @return {Array} The created array.
///
/// @private
function bbmod_array_from_buffer(_buffer, _type, _size)
{
	var _array = array_create(_size, 0);
	var i = 0;
	repeat (_size)
	{
		_array[@ i++] = buffer_read(_buffer, buffer_f32);
	}
	return _array;
}
