/// @func bbmod_set_ibl(sprite, subimage)
/// @desc Changes a sprite used for image based lighting.
/// @param {real} sprite The sprite index.
/// @param {real} subimage The sprite subimage to use.
/// @note This sprite must be a stripe of eight prefiltered octahedrons, the
/// first seven being used for specular lighting and the last one for diffuse
/// lighting.
var _sprite = argument0;
var _subimage = argument1;

global.__bbmod_ibl_sprite = _sprite;
global.__bbmod_ibl_subimage = _sprite;

if (_sprite != noone)
{
	var _material = global.__bbmod_material_current;
	if (_material != undefined)
	{
		var _shader = _material[BBMOD_EMaterial.Shader];
		_bbmod_shader_set_ibl(_shader, _sprite, _subimage);
	}
}