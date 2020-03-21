/// @func b_bbmod_node_render(bbmod, node)
/// @desc Submits a node into a shader for rendering.
/// @param {array} bbmod
/// @param {array} node
var _bbmod = argument0;
var _node = argument1;
var _models = _node[B_EBBMODNode.Models];
var _children = _node[B_EBBMODNode.Children];
var _model_count = array_length_1d(_models);
var _child_count = array_length_1d(_children);
var _materials = _bbmod[B_EBBMOD.Materials];

for (var i/*:int*/= 0; i < _model_count; ++i)
{
	var _model = _models[i];
	var _material_index = _model[B_EBBMODMesh.MaterialIndex];
	var _material = _materials[_material_index];
	var _tex_diffuse = _material[B_EBBMODMaterial.Diffuse];
	vertex_submit(_model[B_EBBMODMesh.VertexBuffer], pr_trianglelist, _tex_diffuse);
}

for (var i/*:int*/= 0; i < _child_count; ++i)
{
	b_bbmod_node_render(_bbmod, _children[i]);
}