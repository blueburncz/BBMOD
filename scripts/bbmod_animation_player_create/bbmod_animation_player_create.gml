/// @func bbmod_animation_player_create(model)
/// @desc Creates a new AnimationPlayer for given Model.
/// @param {array} model A Model structure.
/// @return {array} The created AnimationPlayer structure.
var _model = argument0;
var _bone_count = _model[BBMOD_EModel.BoneCount];

var _anim_player = array_create(BBMOD_EAnimationPlayer.SIZE, 0);
_anim_player[@ BBMOD_EAnimationPlayer.Model] = _model;
_anim_player[@ BBMOD_EAnimationPlayer.Animations] = ds_list_create();
_anim_player[@ BBMOD_EAnimationPlayer.AnimationInstanceLast] = undefined;
_anim_player[@ BBMOD_EAnimationPlayer.BonePositionOverride] = array_create(_bone_count, undefined);
_anim_player[@ BBMOD_EAnimationPlayer.BoneRotationOverride] = array_create(_bone_count, undefined);
return _anim_player;