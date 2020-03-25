/// @func b_bbmod_position_key_to_matrix(position_key)
/// @param {array} position_key
/// @return {array}
gml_pragma("forceinline");
var _position = argument0[B_EBBMODPositionKey.Position];
return matrix_build(
	_position[0],
	_position[1],
	_position[2],
	0, 0, 0,
	1, 1, 1);