/// @func bbmod_bone_load(buffer)
/// @desc Loads a Bone structure from a buffer.
/// @param {real} buffer The buffer to load the structure from.
/// @return {array} The loaded Bone structure.
var _buffer = argument0;

var _bone = array_create(BBMOD_EBone.SIZE, 0);

_bone[@ BBMOD_EBone.Name] = buffer_read(_buffer, buffer_string);
_bone[@ BBMOD_EBone.Index] = buffer_read(_buffer, buffer_f32);
_bone[@ BBMOD_EBone.TransformMatrix] = bbmod_load_matrix(_buffer);
_bone[@ BBMOD_EBone.OffsetMatrix] = bbmod_load_matrix(_buffer);

var _child_count = buffer_read(_buffer, buffer_u32);
var _children = array_create(_child_count, 0);

_bone[@ BBMOD_EBone.Children] = _children;

for (var i/*:int*/= 0; i < _child_count; ++i)
{
	_children[@ i] = bbmod_bone_load(_buffer);
}

return _bone;