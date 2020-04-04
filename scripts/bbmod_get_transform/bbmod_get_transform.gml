/// @func bbmod_get_transform(animation_player)
/// @desc Returns an array of current transformation matrices for animated models.
/// @param {array} animation_player An AnimationPlayer structure.
/// @return {array} The array of transformation matrices.
var _anim_player = argument0;
var _animations = _anim_player[BBMOD_EAnimationPlayer.Animations];

if (!ds_list_empty(_animations))
{
	var _anim_inst = _animations[| 0];
	return _anim_inst[BBMOD_EAnimationInstance.TransformArray];
}

// TODO: A better mechanism to get bindpose transform array?!
var _model = _anim_player[BBMOD_EAnimationPlayer.Model];
var _bone_count = _model[BBMOD_EModel.BoneCount];

var _anim_empty = array_create(BBMOD_EAnimation.SIZE, 0);
_anim_empty[@ BBMOD_EAnimation.Version] = 1;
_anim_empty[@ BBMOD_EAnimation.Duration] = 1;
_anim_empty[@ BBMOD_EAnimation.TicsPerSecond] = 0;
_anim_empty[@ BBMOD_EAnimation.Bones] = array_create(_bone_count, undefined);

var _anim_inst = bbmod_animation_instance_create(_anim_empty);
_anim_inst[BBMOD_EAnimationInstance.TransformArray] = array_create(_bone_count * 16, 0);
bbmod_animate(_anim_player, _anim_inst, 0);
return _anim_inst[BBMOD_EAnimationInstance.TransformArray];