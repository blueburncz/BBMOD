/// @macro {Struct.BBMOD_DefaultShader} A shader for rendering models into the
/// G-buffer.
#macro BBMOD_SHADER_GBUFFER __bbmod_shader_gbuffer()

/// @macro {Struct.BBMOD_DefaultMaterial} An opaque material that can be used
/// with {@link BBMOD_DeferredRenderer}.
#macro BBMOD_MATERIAL_DEFERRED __bbmod_material_deferred()

/// @macro {Struct.BBMOD_TerrainShader} A shader for rendering terrain into
/// the G-buffer. Supports 3 terrain layers at most!
#macro BBMOD_SHADER_TERRAIN_GBUFFER __bbmod_shader_terrain_gbuffer()

/// @macro {Struct.BBMOD_TerrainMaterial} A terrain material that can be used
/// with {@link BBMOD_DeferredRenderer}.
#macro BBMOD_MATERIAL_TERRAIN_DEFERRED __bbmod_material_terrain_deferred()

function __bbmod_shader_gbuffer()
{
	gml_pragma("forceinline");
	static _shader = new BBMOD_DefaultShader(
		             BBMOD_ShGBuffer,              BBMOD_VFORMAT_DEFAULT)
		.add_variant(BBMOD_ShGBufferAnimated,      BBMOD_VFORMAT_DEFAULT_ANIMATED)
		.add_variant(BBMOD_ShGBufferBatched,       BBMOD_VFORMAT_DEFAULT_BATCHED)
		.add_variant(BBMOD_ShGBufferColor,         BBMOD_VFORMAT_DEFAULT_COLOR)
		.add_variant(BBMOD_ShGBufferColorAnimated, BBMOD_VFORMAT_DEFAULT_COLOR_ANIMATED)
		.add_variant(BBMOD_ShGBufferColorBatched,  BBMOD_VFORMAT_DEFAULT_COLOR_BATCHED);
	return _shader;
}

function __bbmod_material_deferred()
{
	gml_pragma("forceinline");
	static _material = new BBMOD_DefaultMaterial()
		.set_shader(BBMOD_ERenderPass.GBuffer, BBMOD_SHADER_GBUFFER);
	return _material;
}

function __bbmod_shader_terrain_gbuffer()
{
	static _shader = undefined;
	if (_shader == undefined)
	{
		_shader = new BBMOD_TerrainShader(BBMOD_ShGBufferTerrain, BBMOD_VFORMAT_DEFAULT);
		_shader.LayersPerDrawCall = 3;
		_shader.MaxLayers = 3;
	}
	return _shader;
}

function __bbmod_material_terrain_deferred()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_TerrainMaterial();
		_material.set_shader(BBMOD_ERenderPass.GBuffer, BBMOD_SHADER_TERRAIN_GBUFFER);
		_material.set_shader(BBMOD_ERenderPass.ReflectionCapture, BBMOD_SHADER_TERRAIN);
		_material.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);
		_material.Repeat = true;
		_material.AlphaTest = 0.01;
		_material.AlphaBlend = false;
	}
	return _material;
}

bbmod_shader_register("BBMOD_SHADER_GBUFFER",         BBMOD_SHADER_GBUFFER);
bbmod_shader_register("BBMOD_SHADER_TERRAIN_GBUFFER", BBMOD_SHADER_TERRAIN_GBUFFER);

bbmod_material_register("BBMOD_MATERIAL_DEFERRED",         BBMOD_MATERIAL_TERRAIN);
bbmod_material_register("BBMOD_MATERIAL_TERRAIN_DEFERRED", BBMOD_MATERIAL_TERRAIN_UNLIT);
