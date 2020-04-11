/// @func bbmod_get_transform(animation_player)
/// @desc Returns an array of current transformation matrices for animated models.
/// @param {array} animation_player An AnimationPlayer structure.
/// @return {array} The array of transformation matrices.
var _anim_player = argument0;
var _animation = _anim_player[BBMOD_EAnimationPlayer.AnimationInstanceLast];

if (!is_undefined(_animation))
{
	return _animation[BBMOD_EAnimationInstance.TransformArray];
}

var _model = _anim_player[BBMOD_EAnimationPlayer.Model];
return bbmod_model_get_bindpose_transform(_model);