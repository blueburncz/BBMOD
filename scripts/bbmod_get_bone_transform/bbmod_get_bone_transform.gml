/// @func bbmod_get_bone_transform(animation_player, bone_index)
/// @desc Returns a transformation matrix of a bone, which can be used
/// for example for attachments.
/// @param {array} animation_player An AnimationPlayer structure.
/// @param {real} bone_index The index of the bone.
/// @return {array} The transformation matrix.
var _anim_player = argument0;
var _bone_index = argument1;
var _anim_inst = _anim_player[BBMOD_EAnimationPlayer.AnimationInstanceLast];

if (is_undefined(_anim_inst))
{
	return matrix_build_identity();
}

return array_get(_anim_inst[BBMOD_EAnimationInstance.BoneTransform], _bone_index);