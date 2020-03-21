/// @func b_bbmod_animation_bone_load(buffer)
/// @param {real} buffer
/// @return {array}
var _buffer = argument0;

var _animation_bone = array_create(B_EBBMODAnimationBone.SIZE, 0);
_animation_bone[@ B_EBBMODAnimationBone.BoneIndex] = buffer_read(_buffer, buffer_f32);

// Load position keys
var _position_key_count = buffer_read(_buffer, buffer_u32);
var _position_keys = array_create(_position_key_count, 0);
_animation_bone[@ B_EBBMODAnimationBone.PositionKeys] = _position_keys;

for (var i/*:int*/= 0; i < _position_key_count; ++i)
{
	var _key = b_bbmod_position_key_load(_buffer);
	_position_keys[@ i] = _key;
}

// Load rotation keys
var _rotation_key_count = buffer_read(_buffer, buffer_u32);
var _rotation_keys = array_create(_rotation_key_count, 0);
_animation_bone[@ B_EBBMODAnimationBone.RotationKeys] = _rotation_keys;

for (var i/*:int*/= 0; i < _rotation_key_count; ++i)
{
	var _key = b_bbmod_rotation_key_load(_buffer);
	_rotation_keys[@ i] = _key;
}

return _animation_bone;