/// @func b_bbmod_node_destroy(node)
/// @param {real} node The id of the node.
var _node = argument0;
var _models = _node[? "models"];

for (var i = ds_list_size(_models) - 1; i >= 0; --i)
{
	vertex_delete_buffer(_models[| i]);
}

var _children = _models[? "children"];

for (var i = ds_list_size(_children) - 1; i >= 0; --i)
{
	b_bbmod_node_destroy(_children[| i]);
}

ds_map_destroy(_node);