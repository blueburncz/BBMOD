/// @func bbmod_animation_player_destroy(animation_player)
/// @desc Frees any memory used by an AnimationPlayer structure.
/// @param {array} animation_player The AnimationPlayer structure.
var _animation_player = argument0;
ds_list_destroy(_animation_player[BBMOD_EAnimationPlayer.Animations]);