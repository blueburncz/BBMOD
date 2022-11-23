/// @macro {Struct.BBMOD_DefaultShader} Shader for terrain materials.
#macro BBMOD_SHADER_TERRAIN __bbmod_shader_terrain()

/// @macro {Struct.BBMOD_DefaultMaterial} Base terrain material.
#macro BBMOD_MATERIAL_TERRAIN __bbmod_material_terrain()

function __bbmod_shader_terrain()
{
	static _shader = new BBMOD_DefaultShader(
		BBMOD_ShTerrain, BBMOD_VFORMAT_DEFAULT);
	return _shader;
}

function __bbmod_material_terrain()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_DefaultMaterial(BBMOD_SHADER_TERRAIN);
		_material.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);
		_material.Mipmapping = mip_on;
		_material.Repeat = true;
		_material.AlphaTest = 0.01;
		_material.AlphaBlend = true;
	}
	return _material;
}

bbmod_shader_register("BBMOD_SHADER_TERRAIN", BBMOD_SHADER_TERRAIN);

bbmod_material_register("BBMOD_MATERIAL_TERRAIN", BBMOD_MATERIAL_TERRAIN);
