/// @func b_bbmod_material_apply(material)
/// @desc Applies given material.
/// @param {array} material The material to apply.
/// @return {bool} True if the material was applied or false if it was already
/// the current one.
var _material = argument0;
if (_material == global.__b_bbmod_material_current)
{
	return false;
}

b_bbmod_material_reset();

var _shader = _material[B_EBBMODMaterial.Shader];
if (shader_current() != _shader)
{
	shader_set(_shader);
	texture_set_stage(shader_get_sampler_index(_shader, "u_texNormal"),
		_material[B_EBBMODMaterial.Normal]);
}

var _blend_mode = _material[B_EBBMODMaterial.BlendMode];
if (gpu_get_blendmode() != _blend_mode)
{
	gpu_set_blendmode(_blend_mode);
}

var _culling = _material[B_EBBMODMaterial.Culling];
if (gpu_get_cullmode() != _culling)
{
	gpu_set_cullmode(_culling);
}

global.__b_bbmod_material_current = _material;

return true;