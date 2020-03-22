/// @func b_bbmod_animate(bbmod, animation, out)
/// @param {array} node
/// @param {string} animation
/// @param {array} out
/// @return {array}
//var _t = get_timer();

var _bbmod = argument0;
var _animation = ds_map_find_value(_bbmod[@ B_EBBMOD.Animations], argument1);
var _array = argument2;

var _anim_stack = global.__b_anim_stack;
var _inverse_transform = _bbmod[B_EBBMOD.InverseTransformMatrix];

ds_stack_push(_anim_stack, _bbmod[B_EBBMOD.Skeleton], matrix_build_identity());

while (!ds_stack_empty(_anim_stack))
{
	var _matrix = ds_stack_pop(_anim_stack);
	var _bone = ds_stack_pop(_anim_stack);

	var _matrix_new = b_bbmod_bone_pose(
		_bone,
		_array,
		_inverse_transform,
		_matrix,
		_animation);

	var _children = _bone[@ B_EBBMODBone.Children];
	var _child_count = array_length_1d(_children);

	for (var i/*:int*/= 0; i < _child_count; ++i)
	{
		ds_stack_push(_anim_stack, _children[i], _matrix_new);
	}
}

//show_debug_message(get_timer() - _t);