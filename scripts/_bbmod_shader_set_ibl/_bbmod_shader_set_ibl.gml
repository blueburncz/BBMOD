/// @func _bbmod_shader_set_ibl(shader, texture, texel)
/// @param {real} shader
/// @param {ptr} texture
/// @param {real} texel
var _shader = argument0;
var _texture = argument1;
var _texel = argument2;

texture_set_stage(shader_get_sampler_index(_shader, "u_texIBL"),
	_texture);
shader_set_uniform_f(shader_get_uniform(_shader, "u_vIBLTexel"),
	_texel, _texel);

texture_set_stage(shader_get_sampler_index(_shader, "u_texBRDF"),
	sprite_get_texture(BBMOD_SprEnvBRDF, 0));