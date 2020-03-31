/// @func bbmod_node_render(bbmod, node, materials)
/// @desc Submits a Node structure for rendering.
/// @param {array} bbmod The BBMOD structure to which the Node belongs.
/// @param {array} node The Node structure.
/// @param {array} materials An array of Material structures, one for each
/// material slot of the BBMOD.
var _bbmod = argument0;
var _node = argument1;
var _materials = argument2;
var _meshes = _node[BBMOD_ENode.Meshes];
var _children = _node[BBMOD_ENode.Children];
var _model_count = array_length_1d(_meshes);
var _child_count = array_length_1d(_children);

for (var i/*:int*/= 0; i < _model_count; ++i)
{
	var _model = _meshes[i];
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