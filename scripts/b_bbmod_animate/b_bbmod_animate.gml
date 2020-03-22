/// @func b_bbmod_animate(bbmod, animation, out)
/// @param {array} node
/// @param {array} animation
/// @param {array} out
/// @return {array}
//var _t = get_timer();

var _bbmod = argument0;
var _animation = argument1;
var _array = argument2;

var _anim_stack = global.__b_anim_stack;
var _inverse_transform = _bbmod[B_EBBMOD.InverseTransformMatrix];

var _animation_duration = _animation[@ B_EBBMODAnimation.Duration];
var _animation_tics_per_sec = _animation[@ B_EBBMODAnimation.TicsPerSecond];

var _time_in_seconds = current_time * 0.001;
var _time_in_tics = _time_in_seconds * _animation_tics_per_sec;
var _animation_time = _time_in_tics mod _animation_duration;

// TODO: Use animation_cache struct!
if (_animation_time < animation_time_last)
{
	position_key_last = array_create(64, 0);
	rotation_key_last = array_create(64, 0);
}
animation_time_last = _animation_time;

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
		_animation,
		_animation_time);

	var _children = _bone[@ B_EBBMODBone.Children];
	var _child_count = array_length_1d(_children);

	for (var i/*:int*/= 0; i < _child_count; ++i)
	{
		ds_stack_push(_anim_stack, _children[i], _matrix_new);
	}
}

//show_debug_message("Animate: " + string(get_timer() - _t) + "us");