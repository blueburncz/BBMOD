/// @func b_bbmod_position_key_load(buffer)
/// @param {real} buffer
/// @return {array}
var _buffer = argument0;
var _key = array_create(B_EBBMODPositionKey.SIZE, 0);
_key[@ B_EBBMODPositionKey.Time] = buffer_read(_buffer, buffer_f64);;
_key[@ B_EBBMODPositionKey.Position] = b_bbmod_load_vec3(_buffer);
return _key;