/// @func bbmod_material_on_apply_default(material)
/// @desc The default material application function.
/// @param {array} material The Material struct.
var _material = argument0;
var _shader = _material[BBMOD_EMaterial.Shader];

texture_set_stage(shader_get_sampler_index(_shader, "u_texNormalRoughness"),
	_material[BBMOD_EMaterial.NormalRoughness]);

texture_set_stage(shader_get_sampler_index(_shader, "u_texMetallicAO"),
	_material[BBMOD_EMaterial.MetallicAO]);

texture_set_stage(shader_get_sampler_index(_shader, "u_texSubsurface"),
	_material[BBMOD_EMaterial.Subsurface]);

texture_set_stage(shader_get_sampler_index(_shader, "u_texEmissive"),
	_material[BBMOD_EMaterial.Emissive]);

var _ibl = global.__bbmod_ibl_texture;

if (_ibl != pointer_null)
{
	_bbmod_shader_set_ibl(_shader, _ibl, global.__bbmod_ibl_texel);
}

_bbmod_shader_set_camera_position(_shader);

_bbmod_shader_set_exposure(_shader);