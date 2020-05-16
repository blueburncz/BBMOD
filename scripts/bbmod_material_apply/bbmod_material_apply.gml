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

// Shader
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

// Gpu state
gpu_set_blendmode(_material[BBMOD_EMaterial.BlendMode]);
gpu_set_cullmode(_material[BBMOD_EMaterial.Culling]);
gpu_set_zwriteenable(_material[BBMOD_EMaterial.ZWrite]);

var _ztest = _material[BBMOD_EMaterial.ZTest];
gpu_set_ztestenable(_ztest);

if (_ztest)
{
	gpu_set_zfunc(_material[BBMOD_EMaterial.ZFunc]);
}

global.__bbmod_material_current = _material;

return true;