/// @func bbmod_node_load(buffer, format, format_mask)
/// @desc Loads a Node structure from a buffer.
/// @param {real} buffer The buffer to load the structure from.
/// @param {real} format A vertex format for node's meshes.
/// @param {real} format_mask A vertex format mask.
/// @return {array} The loaded Node structure.
var _buffer = argument0;
var _format = argument1;
var _mask = argument2;
var i/*:int*/= 0;

var _node = array_create(BBMOD_ENode.SIZE, 0);
_node[@ BBMOD_ENode.Name] = buffer_read(_buffer, buffer_string);

// Models
var _model_count = buffer_read(_buffer, buffer_u32);
var _models = array_create(_model_count, 0);

_node[@ BBMOD_ENode.Meshes] = _models;

//i = 0;
repeat (_model_count)
{
	_models[@ i++] = bbmod_mesh_load(_buffer, _format, _mask);
}

// Child nodes
var _child_count = buffer_read(_buffer, buffer_u32);
var _children = array_create(_child_count, 0);
_node[@ BBMOD_ENode.Children] = _children;

i = 0;
repeat (_child_count)
{
	_children[@ i++] = bbmod_node_load(_buffer, _format, _mask);
}

return _node;