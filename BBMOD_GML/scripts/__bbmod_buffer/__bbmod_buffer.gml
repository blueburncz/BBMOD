/// @module Core

/// @func bbmod_get_scratch_buffer(_sizeMin)
///
/// @desc Returns a buffer that can be used for temporary storage. The buffer
/// will be resized if the current size is smaller than the specified minimum
/// size. The buffer is shared across all calls to this function, so it should
/// not be used for long-term storage or in situations where multiple buffers
/// are needed simultaneously.
///
/// @param {Real} _sizeMin The minimum size of the buffer in bytes. Default
/// value is 1 byte.
///
/// @return {Id.Buffer} The create buffer.
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
