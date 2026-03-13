/// @module Rendering

/// @macro {Struct.BBMOD_Material} A material for rendering physically-based
/// atmospheric sky using the Preetham sky model.
#macro BBMOD_MATERIAL_SKY_PHYSICAL __bbmod_material_sky_physical()

function __bbmod_material_sky_physical()
{
	static _material = undefined;
	if (_material == undefined)
	{
		var _skSky = new BBMOD_Shader(BBMOD_ShSky_Physical, BBMOD_VFORMAT_DEFAULT);
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

bbmod_material_register("BBMOD_MATERIAL_SKY_PHYSICAL", BBMOD_MATERIAL_SKY_PHYSICAL);
