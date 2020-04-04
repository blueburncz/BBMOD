/// @func bbmod_animation_instance_create(animation)
/// @desc Creates a new AnimationInstance structure.
/// @param {array} animation An Animation structure.
/// @return {array} The created structure.
var _anim_inst = array_create(BBMOD_EAnimationInstance.SIZE, 0);
_anim_inst[@ BBMOD_EAnimationInstance.Animation] = argument0;
_anim_inst[@ BBMOD_EAnimationInstance.Loop] = false;
_anim_inst[@ BBMOD_EAnimationInstance.AnimationStart] = undefined;
_anim_inst[@ BBMOD_EAnimationInstance.AnimationTime] = 0;
_anim_inst[@ BBMOD_EAnimationInstance.AnimationTimeLast] = 0;
_anim_inst[@ BBMOD_EAnimationInstance.PositionKeyLast] = 0;
_anim_inst[@ BBMOD_EAnimationInstance.RotationKeyLast] = 0;
_anim_inst[@ BBMOD_EAnimationInstance.TransformArray] = undefined;
return _anim_inst;