/// @func b_bbmod_node_load(buffer, format, format_mask)
/// @param {real} buffer
/// @param {real} format
/// @param {real} format_mask
/// @return {array}
var _buffer = argument0;
var _format = argument1;
var _mask = argument2;

var _node = array_create(B_EBBMODNode.SIZE, 0);
_node[@ B_EBBMODNode.Name] = buffer_read(_buffer, buffer_string);

// Models
var _model_count = buffer_read(_buffer, buffer_u32);
var _models = array_create(_model_count, 0);

_node[@ B_EBBMODNode.Models] = _models;

for (var i/*:int*/= 0; i < _model_count; ++i)
{
	_models[@ i] = b_bbmod_mesh_load(_buffer, _format, _mask);
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