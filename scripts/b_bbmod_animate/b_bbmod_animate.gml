/// @func b_bbmod_animate(node, animation, out)
/// @param {real} node
/// @param {string} animation
/// @param {array} out
/// @return {array}
var _node = argument0;
var _animation = ds_map_find_value(_node[? "animations"], argument1);
var _array = argument2;

b_bbmod_bone_pose(
	_node[? "skeleton"],
	_array,
	_node[? "inverse_transform"],
	matrix_build_identity(),
	_animation);