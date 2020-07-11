/// @func _bbmod_shader_set_ibl(shader, sprite, subimage)
/// @param {real} shader
/// @param {real} sprite
/// @param {real} subimage
var _shader = argument0;
var _sprite = argument1;
var _subimage = argument2;

texture_set_stage(shader_get_sampler_index(_shader, "u_texIBL"),
	sprite_get_texture(_sprite, _subimage));

var _texel = 1 / sprite_get_height(_sprite);

shader_set_uniform_f(shader_get_uniform(_shader, "u_vIBLTexel"),
	_texel, _texel);