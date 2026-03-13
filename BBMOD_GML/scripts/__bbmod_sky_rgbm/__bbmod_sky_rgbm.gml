/// @module Rendering

/// @macro {Struct.BBMOD_Material} A material for rendering RGBM encoded
/// skies.
#macro BBMOD_MATERIAL_SKY_RGBM __bbmod_material_sky_rgbm()

function __bbmod_material_sky_rgbm()
{
	static _material = undefined;
	if (_material == undefined)
	{
		var _skSky = new BBMOD_Shader(BBMOD_ShSky_RGBM, BBMOD_VFORMAT_DEFAULT);
		_material = new BBMOD_Material();
		_material.Persistent = true;
		_material.set_shader(BBMOD_ERenderPass.Background, _skSky);
		_material.set_shader(BBMOD_ERenderPass.ReflectionCapture, _skSky);
		_material.Culling = cull_noculling;
		_material.Mipmapping = mip_off;
		_material.ZWrite = false;
		_material.ZTest = true;
		_material.Filtering = true;
		_material.RenderQueue = BBMOD_ERenderQueue.Sky;
	}
	return _material;
}

bbmod_material_register("BBMOD_MATERIAL_SKY_RGBM", BBMOD_MATERIAL_SKY_RGBM);

////////////////////////////////////////////////////////////////////////////////
// DEPRECATED!!!

/// @macro {Struct.BBMOD_Material} A material for rendering RGBM encoded
/// skies.
/// @deprecated Please use {@link BBMOD_MATERIAL_SKY_RGBM} instead.
#macro BBMOD_MATERIAL_SKY BBMOD_MATERIAL_SKY_RGBM

bbmod_material_register("BBMOD_MATERIAL_SKY", BBMOD_MATERIAL_SKY);
