/// @func bbmod_material_on_apply_default(material)
/// @desc The default material application function.
/// @param {array} material The Material struct.
var _material = argument0;
var _shader = _material[BBMOD_EMaterial.Shader];

texture_set_stage(shader_get_sampler_index(_shader, "u_texNormal"),
	_material[BBMOD_EMaterial.Normal]);