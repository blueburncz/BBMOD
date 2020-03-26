/// @func bbmod_node_destroy(node)
/// @desc Frees resources used by the node from memory.
/// @param {array} node The node to destroy.
var _node = argument0;
var _models = _node[BBMOD_ENode.Models];
var _children = _models[BBMOD_ENode.Children];

for (var i/*:int*/= array_length_1d(_models) - 1; i >= 0; --i)
{
	vertex_delete_buffer(_models[i]);
}

for (var i/*:int*/= array_length_1d(_children) - 1; i >= 0; --i)
{
	bbmod_node_destroy(_children[i]);
}