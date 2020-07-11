/// @func _bbmod_node_freeze(node)
/// @param {array} node
var _node = argument0;
var _meshes = _node[BBMOD_ENode.Meshes];
var _children = _node[BBMOD_ENode.Children];

var i/*:int*/= 0;
repeat (array_length_1d(_meshes))
{
	_bbmod_mesh_freeze(_meshes[i++]);
}

i = 0;
repeat (array_length_1d(_children))
{
	_bbmod_node_freeze(_children[i++]);
}