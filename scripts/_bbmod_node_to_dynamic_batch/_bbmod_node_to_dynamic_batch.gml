/// @func _bbmod_node_to_dynamic_batch(node, dynamic_batch)
/// @param {array} node
/// @param {array} dynamic_batch
var _node = argument0;
var _dynamic_batch = argument1;

var _meshes = _node[BBMOD_ENode.Meshes];
var _children = _node[BBMOD_ENode.Children];
var i/*:int*/= 0;

repeat (array_length_1d(_meshes))
{
	_bbmod_mesh_to_dynamic_batch(_meshes[i++], _dynamic_batch);
}

i = 0;
repeat (array_length_1d(_children))
{
	_bbmod_node_to_dynamic_batch(_children[i++], _dynamic_batch);
}