/// @macro {Struct.BBMOD_BaseMaterial} A material for rendering RGBM encoded
/// skies.
/// @see BBMOD_BaseMaterial
#macro BBMOD_MATERIAL_SKY __bbmod_material_sky()

function __bbmod_material_sky()
{
	static _skyRenderQueue = new BBMOD_RenderQueue("Sky", -$FFFFFFFF);
	static _material = undefined;
	if (_material == undefined)
	{
		var _skSky = new BBMOD_BaseShader(
			BBMOD_ShSky, new BBMOD_VertexFormat(true));
		_material = new BBMOD_BaseMaterial(_skSky);
		_material.Culling = cull_noculling;
		_material.Mipmapping = false;
		_material.ZWrite = false;
		_material.ZTest = false;
		_material.Filtering = true;
		_material.RenderQueue = _skyRenderQueue;
	}
	return _material;
}
