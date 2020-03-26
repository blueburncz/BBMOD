/// @func bbmod_node_render(bbmod, node, materials)
/// @desc Submits a node into a shader for rendering.
/// @param {array} bbmod
/// @param {array} node
/// @param {array} materials
var _bbmod = argument0;
var _node = argument1;
var _materials = argument2;
var _models = _node[BBMOD_ENode.Models];
var _children = _node[BBMOD_ENode.Children];
var _model_count = array_length_1d(_models);
var _child_count = array_length_1d(_children);

for (var i/*:int*/= 0; i < _model_count; ++i)
{
	var _model = _models[i];
	var _material_index = _model[BBMOD_EMesh.MaterialIndex];
	var _material = _materials[_material_index];

	if (bbmod_material_apply(_material))
	{
		// FIXME: transform should be passed as an argument?
		shader_set_uniform_f_array(shader_get_uniform(shader_current(), "u_mBones"), transform);
	}

	var _tex_diffuse = _material[BBMOD_EMaterial.Diffuse];
	vertex_submit(_model[BBMOD_EMesh.VertexBuffer], pr_trianglelist, _tex_diffuse);
}

for (var i/*:int*/= 0; i < _child_count; ++i)
{
	bbmod_node_render(_bbmod, _children[i], _materials);
}