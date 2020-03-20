/// @func b_bbmod_node_render(node)
/// @param {real} node
var _node = argument0;
var _models = _node[? "models"];
var _children = _node[? "children"];

var _model_count = ds_list_size(_models);
var _texture = sprite_get_texture(SprMaterial, 0);

for (var i = 0; i < _model_count; ++i)
{
	vertex_submit(_models[| i], pr_trianglelist, _texture);
}

var _child_count = ds_list_size(_children);

for (var i = 0; i < _child_count; ++i)
{
	b_bbmod_node_render(_children[| i]);
}