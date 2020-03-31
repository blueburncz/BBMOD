/// @func bbmod_position_key_load(buffer)
/// @desc Loads a PositionKey structure from a buffer.
/// @param {real} buffer The buffer to load the structure from.
/// @return {array} The loaded PositionKey structure.
var _buffer = argument0;
var _key = array_create(BBMOD_EPositionKey.SIZE, 0);
_key[@ BBMOD_EPositionKey.Time] = buffer_read(_buffer, buffer_f64);;
_key[@ BBMOD_EPositionKey.Position] = bbmod_load_vec3(_buffer);
return _key;