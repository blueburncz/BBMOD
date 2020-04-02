/// @func bbmod_animation_instance_create()
/// @desc Creates a new AnimationInstance structure.
/// @return {array} The created structure.
var _anim_inst = array_create(BBMOD_EAnimationInstance.SIZE, 0);
_anim_inst[@ BBMOD_EAnimationInstance.Animation] = undefined;
_anim_inst[@ BBMOD_EAnimationInstance.AnimationTimeLast] = 0;
_anim_inst[@ BBMOD_EAnimationInstance.PositionKeyLast] = 0;
_anim_inst[@ BBMOD_EAnimationInstance.RotationKeyLast] = 0;
_anim_inst[@ BBMOD_EAnimationInstance.TransformArray] = undefined;
return _anim_inst;