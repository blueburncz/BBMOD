/// @macro {Struct.BBMOD_VertexFormat} A vertex format of lightmapped models
/// with two UV channels.
#macro BBMOD_VFORMAT_LIGHTMAP __bbmod_vformat_lightmap()

/// @macro {Struct.BBMOD_LightmapShader} Shader for rendering lightmapped models
/// with two UV channels.
#macro BBMOD_SHADER_LIGHTMAP __bbmod_shader_lightmap()

/// @macro {Struct.BBMOD_BaseShader} Depth shader for lightmapped models with
/// two UV channels.
#macro BBMOD_SHADER_LIGHTMAP_DEPTH __bbmod_shader_lightmap_depth()

/// @macro {Struct.BBMOD_LightmapMaterial} Material for lightmapped models with
/// two UV channels.
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
	static _shader = new BBMOD_LightmapShader(
		BBMOD_ShLightmap, __bbmod_vformat_lightmap);
	return _shader;
}

function __bbmod_shader_lightmap_depth()
{
	static _shader = new BBMOD_BaseShader(
		BBMOD_ShLightmapDepth, __bbmod_vformat_lightmap);
	return _shader;
}

function __bbmod_material_lightmap()
{
	static _material = new BBMOD_LightmapMaterial(__bbmod_shader_lightmap());
	return _material;
}
