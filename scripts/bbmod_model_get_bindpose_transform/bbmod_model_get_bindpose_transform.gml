/// @func bbmod_model_get_bindpose_transform(model)
/// @desc Creates a transformation array with model's bindpose.
/// @param {array} model A Model structure.
/// @return {array} The created array.

// TODO: A better mechanism to get bindpose transform array?!

var _model = argument0;
var _bone_count = _model[BBMOD_EModel.BoneCount];

var _anim_empty = array_create(BBMOD_EAnimation.SIZE, 0);
_anim_empty[@ BBMOD_EAnimation.Version] = 1;
_anim_empty[@ BBMOD_EAnimation.Duration] = 1;
_anim_empty[@ BBMOD_EAnimation.TicsPerSecond] = 0;
_anim_empty[@ BBMOD_EAnimation.Bones] = array_create(_bone_count, undefined);

var _anim_inst = bbmod_animation_instance_create(_anim_empty);
_anim_inst[@ BBMOD_EAnimationInstance.BoneTransform] = array_create(_bone_count * 16, 0);
_anim_inst[@ BBMOD_EAnimationInstance.TransformArray] = array_create(_bone_count * 16, 0);
bbmod_animate(_model, _anim_inst, 0);
return _anim_inst[BBMOD_EAnimationInstance.TransformArray];