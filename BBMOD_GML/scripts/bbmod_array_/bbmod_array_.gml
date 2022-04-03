/// @func bbmod_array_find_index(_array, _value)
/// @desc Finds a value within an array and returns its index.
/// @param {Array} _array The array to search in.
/// @param {Mixed} _value The value to search for.
/// @return {Real} Returns the index of the value or -1 if the value is not found.
function bbmod_array_find_index(_array, _value)
{
	var i = 0;
	repeat (array_length(_array))
	{
		if (_array[i] == _value)
		{
			return i;
		}
		++i;
	}
	return -1;
}

/// @func bbmod_array_from_buffer(_buffer, _type, _size)
/// @desc Creates an array with values from a buffer.
/// @param {Id.Buffer} _buffer The buffer to load the data from.
/// @param {Constant.BufferDataType} _type The value type.
/// @param {Real} _size The number of values to load.
/// @return {Array} The created array.
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