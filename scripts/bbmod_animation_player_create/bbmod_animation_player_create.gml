/// @func bbmod_animation_player_create(model)
/// @desc Creates a new AnimationPlayer for given Model.
/// @param {array} model A Model structure.
/// @return {array} The created AnimationPlayer structure.
var _anim_player = array_create(BBMOD_EAnimationPlayer.SIZE, 0);
_anim_player[@ BBMOD_EAnimationPlayer.Model] = argument0;
_anim_player[@ BBMOD_EAnimationPlayer.Animations] = ds_list_create();
return _anim_player;