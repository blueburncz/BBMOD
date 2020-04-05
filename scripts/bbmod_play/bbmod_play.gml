/// @func bbmod_play(animation_player, animation[, loop])
/// @desc Starts playing an animation.
/// @param {struct} animation_player An AnimationPlayer structure.
/// @param {struct} animation An Animation to play.
/// @param {bool} [loop] True to loop the animation. Defaults to false.
var _animation_player = argument[0];
var _animation = argument[1];
var _loop = (argument_count > 2) ? argument[2] : false;

var _animation_list = _animation_player[BBMOD_EAnimationPlayer.Animations]; 
var _animation_last = _animation_player[@ BBMOD_EAnimationPlayer.AnimationInstanceLast];

ds_list_clear(_animation_list);

if (!is_undefined(_animation_last))
{
	var _transition = bbmod_animation_create_transition(
		_animation_player[BBMOD_EAnimationPlayer.Model],
		_animation_last[BBMOD_EAnimationInstance.Animation],
		_animation_last[BBMOD_EAnimationInstance.AnimationTime],
		_animation,
		0,
		0.1);

	var _transition_animation_instance = bbmod_animation_instance_create(_transition);
	ds_list_add(_animation_list, _transition_animation_instance);
}

var _animation_instance = bbmod_animation_instance_create(_animation);
_animation_instance[@ BBMOD_EAnimationInstance.Loop] = _loop;
ds_list_add(_animation_list, _animation_instance);