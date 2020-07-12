/// @func bbmod_dynamic_batch_render(dynamic_batch, material, data)
/// @desc Submits a DynamitBatch for rendering.
/// @param {array} dynamic_batch A DynamicBatch structure.
/// @param {array} material A Material structure. Must use a shader that
/// expects ids in the vertex format.
/// @param {array} data An array containing data for each rendered instance.
var _dynamic_batch = argument0;
var _material = argument1;
var _data = argument2;
var _render_pass = global.bbmod_render_pass;

if ((_material[BBMOD_EMaterial.RenderPath] & _render_pass) == 0)
{
	// Do not render the mesh if it doesn't use a material that can be used
	// in the current render path.
	return;
}

bbmod_material_apply(_material);

_bbmod_shader_set_dynamic_batch_data(_material[BBMOD_EMaterial.Shader], _data);

var _tex_base = _material[BBMOD_EMaterial.BaseOpacity];
vertex_submit(_dynamic_batch[BBMOD_EStaticBatch.VertexBuffer], pr_trianglelist, _tex_base);