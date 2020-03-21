/// @func b_bbmod_node_render(node)
/// @desc Submits a node into a shader for rendering.
/// @param {array} node
var _node = argument0;
var _models = _node[B_EBBMODNode.Models];
var _children = _node[B_EBBMODNode.Children];
var _model_count = array_length_1d(_models);
var _child_count = array_length_1d(_children);
var _tex_diffuse = sprite_get_texture(SprMaterial, 0);

for (var i = 0; i < _model_count; ++i)
{
	vertex_submit(_models[i], pr_trianglelist, _tex_diffuse);
}

for (var i = 0; i < _child_count; ++i)
{
	b_bbmod_node_render(_children[i]);
}