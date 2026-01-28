/// @module Core

/// @func bbmod_get_scratch_buffer(_sizeMin)
///
/// @desc
///
/// @param {Real} _sizeMin
///
/// @return {Id.Buffer}
function bbmod_get_scratch_buffer(_sizeMin = 1)
{
	static _buffer = buffer_create(_sizeMin, buffer_grow, 1);
	var _bufferSize = buffer_get_size(_buffer);
	if (_bufferSize < _sizeMin)
	{
		buffer_resize(_buffer, _sizeMin);
	}
	buffer_seek(_buffer, buffer_seek_start, 0);
	return _buffer;
}
