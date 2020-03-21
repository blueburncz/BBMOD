/// @func b_bbmod_node_load(buffer, format, formatMask)
/// @param {real} buffer
/// @param {real} format
/// @param {real} formatMask
/// @return {array}
var _buffer = argument0;
var _format = argument1;
var _mask = argument2;

var _has_vertices = (_mask >> B_BBMOD_VFORMAT_VERTEX) & 1;
var _has_normals = (_mask >> B_BBMOD_VFORMAT_NORMAL) & 1;
var _has_uvs = (_mask >> B_BBMOD_VFORMAT_TEXCOORD) & 1;
var _has_colors = (_mask >> B_BBMOD_VFORMAT_COLOR) & 1;
var _has_tangentw = (_mask >> B_BBMOD_VFORMAT_TANGENTW) & 1;
var _has_bones = (_mask >> B_BBMOD_VFORMAT_BONES) & 1;

var _node = array_create(B_EBBMODNode.SIZE, 0);
_node[@ B_EBBMODNode.Name] = buffer_read(_buffer, buffer_string);

// Models
var _model_count = buffer_read(_buffer, buffer_u32);
var _models = array_create(_model_count, 0);

_node[@ B_EBBMODNode.Models] = _models;

for (var i/*:int*/= 0; i < _model_count; ++i)
{
	var _vertex_count = buffer_read(_buffer, buffer_u32);
	if (_vertex_count > 0)
	{
		var _size = _vertex_count * (0
			+ _has_vertices * 3 * buffer_sizeof(buffer_f32)
			+ _has_normals * 3 * buffer_sizeof(buffer_f32)
			+ _has_uvs * 2 * buffer_sizeof(buffer_f32)
			+ _has_colors * buffer_sizeof(buffer_u32)
			+ _has_tangentw * 4 * buffer_sizeof(buffer_f32)
			+ _has_bones * 8 * buffer_sizeof(buffer_f32));

		if (_size > 0)
		{
			var _vbuffer = vertex_create_buffer_from_buffer_ext(
				_buffer, _format, buffer_tell(_buffer), _vertex_count);
			vertex_freeze(_vbuffer);
			_models[@ i] = _vbuffer;
			buffer_seek(_buffer, buffer_seek_relative, _size);
		}
	}
}

// Child nodes
var _child_count = buffer_read(_buffer, buffer_u32);
var _children = array_create(_child_count, 0);
_node[@ B_EBBMODNode.Children] = _children;

for (var i/*:int*/= 0; i < _child_count; ++i)
{
	_children[@ i] = b_bbmod_node_load(_buffer, _format, _mask);
}

return _node;