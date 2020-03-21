/// @func b_bbmod_animate(bbmod, animation, out)
/// @param {array} node
/// @param {string} animation
/// @param {array} out
/// @return {array}
var _bbmod = argument0;
var _animation = ds_map_find_value(_bbmod[@ B_EBBMOD.Animations], argument1);
var _array = argument2;

b_bbmod_bone_pose(
	_bbmod[B_EBBMOD.Skeleton],
	_array,
	_bbmod[B_EBBMOD.InverseTransformMatrix],
	matrix_build_identity(),
	_animation);