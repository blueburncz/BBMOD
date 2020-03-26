/// @func bbmod_animation(buffer, version)
/// @param {real} buffer
/// @param {real} version
/// @return {array}
var _buffer = argument0;
var _version = argument1;

var _animation = array_create(BBMOD_EAnimation.SIZE, 0);
_animation[@ BBMOD_EAnimation.Version] = _version;
_animation[@ BBMOD_EAnimation.Duration] = buffer_read(_buffer, buffer_f64);
_animation[@ BBMOD_EAnimation.TicsPerSecond] = buffer_read(_buffer, buffer_f64);

var _mesh_bone_count = buffer_read(_buffer, buffer_u32);

var _bones = array_create(_mesh_bone_count, undefined);
_animation[@ BBMOD_EAnimation.Bones] = _bones;

var _affected_bone_count = buffer_read(_buffer, buffer_u32);

repeat (_affected_bone_count)
{
	var _bone_data = bbmod_animation_bone_load(_buffer);
	var _bone_index = _bone_data[BBMOD_EAnimationBone.BoneIndex];
	_bones[@ _bone_index] = _bone_data;
}

return _animation;