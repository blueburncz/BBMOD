/// @func b_bbmod_node_load(buffer, format, formatMask)
/// @param {real} buffer
/// @param {real} format
/// @param {real} formatMask
/// @return {real}
var _buffer = argument0;
var _format = argument1;
var _mask = argument2;

var _has_vertices = (_mask & 1);
var _has_normals = (_mask > 1) & 1;
var _has_uvs = (_mask > 2) & 1;
var _has_colors = (_mask > 3) & 1;
var _has_tangentw = (_mask > 4) & 1;
var _has_bones = (_mask > 5) & 1;

var _node = ds_map_create();
var _name = buffer_read(_buffer, buffer_string);
_node[? "name"] = _name;
show_debug_message(_name);

// Models
var _model_count = buffer_read(_buffer, buffer_u32);
show_debug_message(_model_count);
var _models = ds_list_create();
ds_map_add_list(_node, "models", _models);

repeat (_model_count)
{
	var _vertex_count = buffer_read(_buffer, buffer_u32);
	if (_vertex_count > 0)
	{
		var _size = (_has_vertices * 3 * buffer_sizeof(buffer_f32)
			+ _has_normals * 3 * buffer_sizeof(buffer_f32)
			+ _has_uvs * 2 * buffer_sizeof(buffer_f32)
			+ _has_colors * buffer_sizeof(buffer_u32)
			+ _has_tangentw * 4 * buffer_sizeof(buffer_f32)
			+ _has_bones * 8 * buffer_sizeof(buffer_f32))
			* _vertex_count;

		if (_size > 0)
		{
			var _vbuffer = vertex_create_buffer_from_buffer_ext(
				_buffer, _format, buffer_tell(_buffer), _vertex_count);

			vertex_freeze(_vbuffer);
			ds_list_add(_models, _vbuffer);
			buffer_seek(_buffer, buffer_seek_relative, _size);
		}
	}
}

// Child nodes
var _children = ds_list_create();
ds_map_add_list(_node, "children", _children);

var _child_count = buffer_read(_buffer, buffer_u32);
show_debug_message(_child_count);

repeat (_child_count)
{
	ds_list_add(_children, b_bbmod_node_load(_buffer, _format, _mask));
}

return _node;