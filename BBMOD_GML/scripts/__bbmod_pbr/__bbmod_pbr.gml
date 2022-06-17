/// @macro {Struct.BBMOD_PBRMaterial} A material for rendering RGBM encoded skies.
/// @see BBMOD_PBRMaterial
#macro BBMOD_MATERIAL_SKY __bbmod_material_sky()

function __bbmod_shader_pbr()
{
	static _shader = new BBMOD_PBRShader(BBMOD_ShPBR, BBMOD_VFORMAT_DEFAULT);
	return _shader;
}

function __bbmod_shader_pbr_animated()
{
	static _shader = new BBMOD_PBRShader(BBMOD_ShPBRAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED);
	return _shader;
}

function __bbmod_shader_pbr_batched()
{
	static _shader = new BBMOD_PBRShader(BBMOD_ShPBRBatched, BBMOD_VFORMAT_DEFAULT_BATCHED);
	return _shader;
}

function __bbmod_material_pbr()
{
	static _material = new BBMOD_PBRMaterial(BBMOD_SHADER_PBR);
	return _material;
}

function __bbmod_material_pbr_animated()
{
	static _material = new BBMOD_PBRMaterial(BBMOD_SHADER_PBR_ANIMATED);
	return _material;
}

function __bbmod_material_pbr_batched()
{
	static _material = new BBMOD_PBRMaterial(BBMOD_SHADER_PBR_BATCHED);
	return _material;
}

function __bbmod_material_sky()
{
	static _skyRenderQueue = new BBMOD_RenderQueue("Sky", -$FFFFFFFF);
	static _material = undefined;
	if (_material == undefined)
	{
		var _skSky = new BBMOD_BaseShader(BBMOD_ShSky, new BBMOD_VertexFormat(true));
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
