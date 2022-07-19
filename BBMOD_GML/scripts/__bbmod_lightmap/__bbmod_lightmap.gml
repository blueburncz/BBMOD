/// @macro {Struct.BBMOD_VertexFormat} A vertex format of models with two
/// UV channels, the second one being used for lightmaps.
#macro BBMOD_VFORMAT_LIGHTMAP __bbmod_vformat_lightmap()

/// @macro {Struct.BBMOD_DefaultShader} Shader for rendering models with
/// two UV channels, the second one being used for lightmaps.
#macro BBMOD_SHADER_LIGHTMAP __bbmod_shader_lightmap()

/// @macro {Struct.BBMOD_DefaultMaterial} Material for models with two UV
/// channels, the second one being used for lightmaps.
#macro BBMOD_MATERIAL_LIGHTMAP __bbmod_material_lightmap()

function __bbmod_vformat_lightmap()
{
	static _vformat = new BBMOD_VertexFormat({
		"Vertices": true,
		"Normals": true,
		"TextureCoords": true,
		"TextureCoords2": true,
		"TangentW": true,
	});
	return _vformat;
}

function __bbmod_shader_lightmap()
{
	static _shader = new BBMOD_DefaultShader(
		BBMOD_ShLightmap, __bbmod_vformat_lightmap);
	return _shader;
}

function __bbmod_material_lightmap()
{
	static _material = new BBMOD_DefaultMaterial(__bbmod_shader_lightmap());
	return _material;
}
