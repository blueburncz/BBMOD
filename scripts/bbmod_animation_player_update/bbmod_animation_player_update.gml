/// @func bbmod_animation_player_update(animation_player, current_time)
/// @desc Updates an AnimationPlayer structure. Should be call each frame.
/// @param {array} animation_player The AnimationPlayer structure.
/// @param {real} current_time The current time in seconds.
var _anim_player = argument0;
var _current_time = argument1;
var _model = _anim_player[BBMOD_EAnimationPlayer.Model];
var _animations = _anim_player[BBMOD_EAnimationPlayer.Animations];

repeat (ds_list_size(_animations))
{
	var _anim_inst = _animations[| 0];

	if (is_undefined(_anim_inst[BBMOD_EAnimationInstance.AnimationStart]))
	{
		_anim_inst[@ BBMOD_EAnimationInstance.AnimationStart] = _current_time;
	}
	var _animation_start = _anim_inst[BBMOD_EAnimationInstance.AnimationStart];

	var _animation = _anim_inst[BBMOD_EAnimationInstance.Animation];

	var _animation_time = bbmod_get_animation_time(_animation, _current_time - _animation_start);
	var _looped = (_animation_time < _anim_inst[BBMOD_EAnimationInstance.AnimationTimeLast]);

	if (_looped && !_anim_inst[BBMOD_EAnimationInstance.Loop])
	{
		ce_trigger_event(BBMOD_EV_ANIMATION_END, _animation);
		ds_list_delete(_animations, 0);
		continue;
	}

	_anim_inst[@ BBMOD_EAnimationInstance.AnimationTime] = _animation_time;

	var _bone_count = array_length_1d(_animation[BBMOD_EAnimation.Bones]);
	var _initialized = (!is_undefined(_anim_inst[BBMOD_EAnimationInstance.BoneTransform])
		&& !is_undefined(_anim_inst[BBMOD_EAnimationInstance.TransformArray]));

	if (!_initialized)
	{
		_anim_inst[@ BBMOD_EAnimationInstance.BoneTransform] =
			array_create(_bone_count * 16, 0);
		_anim_inst[@ BBMOD_EAnimationInstance.TransformArray] =
			array_create(_bone_count * 16, 0);
	}

	if (!_initialized || _looped)
	{
		_anim_inst[@ BBMOD_EAnimationInstance.PositionKeyLast] =
			array_create(_bone_count, 0);
		_anim_inst[@ BBMOD_EAnimationInstance.RotationKeyLast] =
			array_create(_bone_count, 0);
	}

	_anim_inst[@ BBMOD_EAnimationInstance.AnimationTimeLast] = _animation_time;

	bbmod_animate(_anim_player, _anim_inst, _animation_time);

	_anim_player[@ BBMOD_EAnimationPlayer.AnimationInstanceLast] = _anim_inst;
}
