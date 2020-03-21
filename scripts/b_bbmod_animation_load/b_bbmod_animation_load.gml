/// @func b_bbmod_animation(buffer)
/// @param {real} buffer
/// @return {array}
var _buffer = argument0;

var _animation = array_create(B_EBBMODAnimation.SIZE, 0);
_animation[@ B_EBBMODAnimation.Name] = buffer_read(_buffer, buffer_string);
_animation[@ B_EBBMODAnimation.Duration] =  buffer_read(_buffer, buffer_f64);
_animation[@ B_EBBMODAnimation.TicsPerSecond] =  buffer_read(_buffer, buffer_f64);

var _affected_bone_count = buffer_read(_buffer, buffer_u32);
var _bones = ds_map_create()
_animation[@ B_EBBMODAnimation.Bones] = _bones;

repeat (_affected_bone_count)
{
	var _bone_data = b_bbmod_animation_bone_load(_buffer);
	var _bone_index = _bone_data[B_EBBMODAnimationBone.BoneIndex];
	ds_map_add(_bones, _bone_index, _bone_data);
}

return _animation;