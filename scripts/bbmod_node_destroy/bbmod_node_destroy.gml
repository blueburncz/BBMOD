/// @func bbmod_node_destroy(node)
/// @desc Frees resources used by the Node structure from memory.
/// @param {array} node The Node structure to destroy.
var _node = argument0;
var _meshes = _node[BBMOD_ENode.Meshes];
var _children = _meshes[BBMOD_ENode.Children];

for (var i/*:int*/= array_length_1d(_meshes) - 1; i >= 0; --i)
{
	vertex_delete_buffer(_meshes[i]);
}

for (var i/*:int*/= array_length_1d(_children) - 1; i >= 0; --i)
{
	bbmod_node_destroy(_children[i]);
}