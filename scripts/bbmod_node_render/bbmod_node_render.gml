/// @func bbmod_node_render(model, node, materials, transform)
/// @desc Submits a Node structure for rendering.
/// @param {array} model The Model structure to which the Node belongs.
/// @param {array} node The Node structure.
/// @param {array} materials An array of Material structures, one for each
/// material slot of the Model.
/// @param {array/undefined} transform An array of transformation matrices
/// (for animated models) or `undefined`.
var _model = argument0;
var _node = argument1;
var _materials = argument2;
var _transform = argument3;
var _meshes = _node[BBMOD_ENode.Meshes];
var _children = _node[BBMOD_ENode.Children];
var _render_pass = global.bbmod_render_pass;
var i/*:int*/= 0;

repeat (array_length_1d(_meshes))
{
	var _model = _meshes[i++];
	var _material_index = _model[BBMOD_EMesh.MaterialIndex];
	var _material = _materials[_material_index];

	if ((_material[BBMOD_EMaterial.RenderPath] & _render_pass) == 0)
	{
		// Do not render the mesh if it doesn't use a material that can be used
		// in the current render path.
		continue;
	}

	if (bbmod_material_apply(_material) && !is_undefined(_transform))
	{
		shader_set_uniform_f_array(shader_get_uniform(shader_current(), "u_mBones"), _transform);
	}

	var _tex_base = _material[BBMOD_EMaterial.BaseOpacity];
	vertex_submit(_model[BBMOD_EMesh.VertexBuffer], pr_trianglelist, _tex_base);
}

i = 0;
repeat (array_length_1d(_children))
{
	bbmod_node_render(_model, _children[i++], _materials, _transform);
}