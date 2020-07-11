/// @func bbmod_static_batch_render(static_batch, material)
/// @desc Submits a StaticBatch for rendering.
/// @param {array} static_batch A StaticBatch structure.
/// @param {array} material A Material structure.
var _static_batch = argument0;
var _material = argument1;
var _render_pass = global.bbmod_render_pass;

if ((_material[BBMOD_EMaterial.RenderPath] & _render_pass) == 0)
{
	// Do not render the mesh if it doesn't use a material that can be used
	// in the current render path.
	return;
}

bbmod_material_apply(_material);
var _tex_base = _material[BBMOD_EMaterial.BaseOpacity];
vertex_submit(_static_batch[BBMOD_EStaticBatch.VertexBuffer], pr_trianglelist, _tex_base);