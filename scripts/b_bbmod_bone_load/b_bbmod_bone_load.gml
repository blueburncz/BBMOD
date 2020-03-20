/// @func b_bbmod_bone_load(buffer)
/// @param buffer
/// @param {real} buffer
/// @return {real}
var _buffer = argument0;

var _bone = ds_map_create();

var _name = buffer_read(_buffer, buffer_string);
show_debug_message(_name);
_bone[? "name"] = _name;

var _index = buffer_read(_buffer, buffer_f32);
show_debug_message(_index);
_bone[? "index"] = _index;

var _transform = b_bbmod_load_matrix(_buffer);
show_debug_message(_transform);
_bone[? "transform"] = _transform;

var _offset = b_bbmod_load_matrix(_buffer);
show_debug_message(_offset);
_bone[? "offset"] = _offset;

var _children = ds_list_create();
ds_map_add_list(_bone, "children", _children);

var _child_count = buffer_read(_buffer, buffer_u32);
show_debug_message(_child_count);

repeat (_child_count)
{
	ds_list_add(_children, b_bbmod_bone_load(_buffer));
}

return _bone;