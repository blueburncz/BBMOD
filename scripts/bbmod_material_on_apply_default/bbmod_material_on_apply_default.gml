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

// TODO: Add API for setting the sky texture
texture_set_stage(shader_get_sampler_index(_shader, "u_texDiffuseIBL"),
	sprite_get_texture(spr_sky_diffuse, 0));

var _specularEnv = spr_sky_specular;

texture_set_stage(shader_get_sampler_index(_shader, "u_texSpecularIBL"),
	sprite_get_texture(_specularEnv, 0));

var _texel = 1 / sprite_get_height(_specularEnv);

shader_set_uniform_f(shader_get_uniform(_shader, "u_vSpecularIBLTexel"),
	_texel, _texel);

texture_set_stage(shader_get_sampler_index(_shader, "u_texBRDF"),
	sprite_get_texture(BBMOD_SprEnvBRDF, 0));

shader_set_uniform_f(shader_get_uniform(_shader, "u_vCamPos"),
	x, y, z);

shader_set_uniform_f(shader_get_uniform(_shader, "u_fExposure"),
	exposure);