/// @func bbmod_material_apply(material)
/// @desc Applies a material.
/// @param {array} material A Material structure.
/// @return {bool} True if the material was applied or false if it was already
/// the current one.
var _material = argument0;
if (_material == global.__bbmod_material_current)
{
	return false;
}

bbmod_material_reset();

var _shader = _material[BBMOD_EMaterial.Shader];
if (shader_current() != _shader)
{
	shader_set(_shader);

	var _on_apply = _material[BBMOD_EMaterial.OnApply];
	if (!is_undefined(_on_apply))
	{
		script_execute(_on_apply, _material);
	}
}

var _blend_mode = _material[BBMOD_EMaterial.BlendMode];
if (gpu_get_blendmode() != _blend_mode)
{
	gpu_set_blendmode(_blend_mode);
}

var _culling = _material[BBMOD_EMaterial.Culling];
if (gpu_get_cullmode() != _culling)
{
	gpu_set_cullmode(_culling);
}

global.__bbmod_material_current = _material;

return true;