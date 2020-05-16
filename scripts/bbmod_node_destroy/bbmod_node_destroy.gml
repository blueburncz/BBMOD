/// @func bbmod_node_destroy(node)
/// @desc Frees resources used by the Node structure from memory.
/// @param {array} node The Node structure to destroy.
var _node = argument0;
var _meshes = _node[BBMOD_ENode.Meshes];
var _children = _meshes[BBMOD_ENode.Children];
var i/*:int*/= 0;

//i = 0;
repeat (array_length_1d(_meshes))
{
	vertex_delete_buffer(_meshes[i++]);
}

i = 0;
repeat (array_length_1d(_children))
{
	bbmod_node_destroy(_children[i++]);
}