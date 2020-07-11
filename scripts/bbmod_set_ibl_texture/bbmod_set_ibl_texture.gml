/// @func bbmod_set_ibl_texture(texture, texel)
/// @desc Changes a texture used for image based lighting.
/// @param {real} texture The texture.
/// @param {real} texel A size of one texel.
/// @note This texture must be a stripe of eight prefiltered octahedrons, the
/// first seven being used for specular lighting and the last one for diffuse
/// lighting.
var _texture = argument0;
var _texel = argument1;

global.__bbmod_ibl_texture = _texture;
global.__bbmod_ibl_texel = _texel;

if (_texture != pointer_null)
{
	var _material = global.__bbmod_material_current;
	if (_material != undefined)
	{
		var _shader = _material[BBMOD_EMaterial.Shader];
		_bbmod_shader_set_ibl(_shader, _texture, _texel);
	}
}