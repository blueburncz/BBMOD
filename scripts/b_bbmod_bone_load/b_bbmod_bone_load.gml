/// @func b_bbmod_bone_load(buffer)
/// @param {real} buffer
/// @return {array}
var _buffer = argument0;

var _bone = array_create(B_EBBMODBone.SIZE, 0);

_bone[@ B_EBBMODBone.Name] = buffer_read(_buffer, buffer_string);
_bone[@ B_EBBMODBone.Index] = buffer_read(_buffer, buffer_f32);
_bone[@ B_EBBMODBone.TransformMatrix] = b_bbmod_load_matrix(_buffer);
_bone[@ B_EBBMODBone.OffsetMatrix] = b_bbmod_load_matrix(_buffer);

var _child_count = buffer_read(_buffer, buffer_u32);
var _children = array_create(_child_count, 0);

_bone[@ B_EBBMODBone.Children] = _children;

for (var i/*:int*/= 0; i < _child_count; ++i)
{
	_children[@ i] = b_bbmod_bone_load(_buffer);
}

return _bone;