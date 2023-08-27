/// @module Core

/// @macro {Struct.BBMOD_VertexFormat} A vertex format of lightmapped models
/// with two UV channels.
#macro BBMOD_VFORMAT_DEFAULT_LIGHTMAP __bbmod_vformat_default_lightmap()

/// @macro {Struct.BBMOD_VertexFormat} Vertex format of 2D sprites.
#macro BBMOD_VFORMAT_DEFAULT_SPRITE __bbmod_vformat_default_sprite()

/// @macro {Struct.BBMOD_DefaultShader} The default shader.
#macro BBMOD_SHADER_DEFAULT __bbmod_shader_default()

/// @macro {Struct.BBMOD_DefaultShader} The default shader for unlit objects.
#macro BBMOD_SHADER_DEFAULT_UNLIT __bbmod_shader_default_unlit()

/// @macro {Struct.BBMOD_BaseShader} The default depth shader.
///
/// @example
/// Following code enables casting shadows for a custom material
/// (requires a {@link BBMOD_BaseRenderer} with enabled shadows).
/// ```gml
/// material = BBMOD_MATERIAL_DEFAULT.clone()
///     .set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);
/// ```
///
/// @see BBMOD_ERenderPass.Shadows
#macro BBMOD_SHADER_DEFAULT_DEPTH __bbmod_shader_default_depth()

/// @macro {Struct.BBMOD_LightmapShader} Shader for rendering lightmapped models
/// with two UV channels.
/// @note This shader does not support subsurface scattering!
#macro BBMOD_SHADER_DEFAULT_LIGHTMAP __bbmod_shader_default_lightmap()

/// @macro {Struct.BBMOD_DefaultSpriteShader} Shader for 2D sprites.
#macro BBMOD_SHADER_DEFAULT_SPRITE __bbmod_shader_default_sprite()

/// @macro {Struct.BBMOD_DefaultMaterial} The default material.
#macro BBMOD_MATERIAL_DEFAULT __bbmod_material_default()

/// @macro {Struct.BBMOD_DefaultMaterial} The default material for unlit objects.
#macro BBMOD_MATERIAL_DEFAULT_UNLIT __bbmod_material_default_unlit()

/// @macro {Struct.BBMOD_LightmapMaterial} Material for lightmapped models with
/// two UV channels.
/// @macro This material does not support subsurface scattering!
#macro BBMOD_MATERIAL_DEFAULT_LIGHTMAP __bbmod_material_default_lightmap()

/// @macro {Struct.BBMOD_DefaultMaterial} Material for 2D sprites.
#macro BBMOD_MATERIAL_DEFAULT_SPRITE __bbmod_material_default_sprite()

////////////////////////////////////////////////////////////////////////////////
// Vertex formats

function __bbmod_vformat_default_lightmap()
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

function __bbmod_vformat_default_sprite()
{
	static _vformat = new BBMOD_VertexFormat(
		true, false, true, true, false, false, false);
	return _vformat;
}

////////////////////////////////////////////////////////////////////////////////
// Shaders

function __bbmod_shader_default()
{
	static _shader = new BBMOD_DefaultShader(
		             BBMOD_ShDefault,              BBMOD_VFORMAT_DEFAULT)
		.add_variant(BBMOD_ShDefaultAnimated,      BBMOD_VFORMAT_DEFAULT_ANIMATED)
		.add_variant(BBMOD_ShDefaultBatched,       BBMOD_VFORMAT_DEFAULT_BATCHED)
		.add_variant(BBMOD_ShDefaultColor,         BBMOD_VFORMAT_DEFAULT_COLOR)
		.add_variant(BBMOD_ShDefaultColorAnimated, BBMOD_VFORMAT_DEFAULT_COLOR_ANIMATED)
		.add_variant(BBMOD_ShDefaultColorBatched,  BBMOD_VFORMAT_DEFAULT_COLOR_BATCHED)
		;
	return _shader;
}

function __bbmod_shader_default_unlit()
{
	static _shader = new BBMOD_DefaultShader(
		             BBMOD_ShDefaultUnlit,              BBMOD_VFORMAT_DEFAULT)
		.add_variant(BBMOD_ShDefaultUnlitAnimated,      BBMOD_VFORMAT_DEFAULT_ANIMATED)
		.add_variant(BBMOD_ShDefaultUnlitBatched,       BBMOD_VFORMAT_DEFAULT_BATCHED)
		.add_variant(BBMOD_ShDefaultUnlitColor,         BBMOD_VFORMAT_DEFAULT_COLOR)
		.add_variant(BBMOD_ShDefaultUnlitColorAnimated, BBMOD_VFORMAT_DEFAULT_COLOR_ANIMATED)
		.add_variant(BBMOD_ShDefaultUnlitColorBatched,  BBMOD_VFORMAT_DEFAULT_COLOR_BATCHED)
		;
	return _shader;
}

function __bbmod_shader_default_lightmap()
{
	static _shader = new BBMOD_DefaultLightmapShader(
		BBMOD_ShDefaultLightmap, BBMOD_VFORMAT_DEFAULT_LIGHTMAP);
	return _shader;
}

function __bbmod_shader_default_sprite()
{
	static _shader = new BBMOD_DefaultSpriteShader(
		BBMOD_ShDefaultSprite, BBMOD_VFORMAT_DEFAULT_SPRITE)
	return _shader;
}

function __bbmod_shader_default_depth()
{
	static _shader = new BBMOD_BaseShader(
		             BBMOD_ShDefaultDepth,              BBMOD_VFORMAT_DEFAULT)
		.add_variant(BBMOD_ShDefaultDepthAnimated,      BBMOD_VFORMAT_DEFAULT_ANIMATED)
		.add_variant(BBMOD_ShDefaultDepthBatched,       BBMOD_VFORMAT_DEFAULT_BATCHED)
		.add_variant(BBMOD_ShDefaultDepthLightmap,      BBMOD_VFORMAT_DEFAULT_LIGHTMAP)
		.add_variant(BBMOD_ShDefaultDepthColor,         BBMOD_VFORMAT_DEFAULT_COLOR)
		.add_variant(BBMOD_ShDefaultDepthColorAnimated, BBMOD_VFORMAT_DEFAULT_COLOR_ANIMATED)
		.add_variant(BBMOD_ShDefaultDepthColorBatched,  BBMOD_VFORMAT_DEFAULT_COLOR_BATCHED)
		;
	return _shader;
}

////////////////////////////////////////////////////////////////////////////////
// Materials

function __bbmod_material_default()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_DefaultMaterial(BBMOD_SHADER_DEFAULT);
		_material.BaseOpacity = sprite_get_texture(BBMOD_SprWhite, 0);
	}
	return _material;
}

function __bbmod_material_default_unlit()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_DefaultMaterial(BBMOD_SHADER_DEFAULT_UNLIT);
		_material.BaseOpacity = sprite_get_texture(BBMOD_SprWhite, 0);
	}
	return _material;
}

function __bbmod_material_default_lightmap()
{
	static _material = new BBMOD_DefaultLightmapMaterial(BBMOD_SHADER_DEFAULT_LIGHTMAP);
	return _material;
}

function __bbmod_material_default_sprite()
{
	static _material = new BBMOD_DefaultMaterial(BBMOD_SHADER_DEFAULT_SPRITE);
	return _material;
}

////////////////////////////////////////////////////////////////////////////////
// Register

bbmod_shader_register("BBMOD_SHADER_DEFAULT",          BBMOD_SHADER_DEFAULT);
bbmod_shader_register("BBMOD_SHADER_DEFAULT_UNLIT",    BBMOD_SHADER_DEFAULT_UNLIT);
bbmod_shader_register("BBMOD_SHADER_DEFAULT_DEPTH",    BBMOD_SHADER_DEFAULT_DEPTH);
bbmod_shader_register("BBMOD_SHADER_DEFAULT_LIGHTMAP", BBMOD_SHADER_DEFAULT_LIGHTMAP);
bbmod_shader_register("BBMOD_SHADER_DEFAULT_SPRITE",   BBMOD_SHADER_DEFAULT_SPRITE);

bbmod_material_register("BBMOD_MATERIAL_DEFAULT",          BBMOD_MATERIAL_DEFAULT);
bbmod_material_register("BBMOD_MATERIAL_DEFAULT_UNLIT",    BBMOD_MATERIAL_DEFAULT_UNLIT);
bbmod_material_register("BBMOD_MATERIAL_DEFAULT_LIGHTMAP", BBMOD_MATERIAL_DEFAULT_LIGHTMAP);
bbmod_material_register("BBMOD_MATERIAL_DEFAULT_SPRITE",   BBMOD_MATERIAL_DEFAULT_SPRITE);

////////////////////////////////////////////////////////////////////////////////
// DEPRECATED!!!

/// @macro {Struct.BBMOD_VertexFormat} Vertex format of 2D sprites.
/// @deprecated Please use {@link BBMOD_VFORMAT_DEFAULT_SPRITE} instead.
#macro BBMOD_VFORMAT_SPRITE BBMOD_VFORMAT_DEFAULT_SPRITE

/// @macro {Struct.BBMOD_VertexFormat} A vertex format of lightmapped models
/// with two UV channels.
/// @deprecated Please use {@link BBMOD_VFORMAT_DEFAULT_LIGHTMAP} instead.
#macro BBMOD_VFORMAT_LIGHTMAP BBMOD_VFORMAT_DEFAULT_LIGHTMAP

/// @macro {Struct.BBMOD_DefaultShader} The default shader for animated models.
/// @deprecated Please use {@link BBMOD_SHADER_DEFAULT} instead.
#macro BBMOD_SHADER_DEFAULT_ANIMATED BBMOD_SHADER_DEFAULT

/// @macro {Struct.BBMOD_DefaultShader} The default shader for dynamically
/// batched models.
/// @see BBMOD_DynamicBatch
/// @deprecated Please use {@link BBMOD_SHADER_DEFAULT} instead.
#macro BBMOD_SHADER_DEFAULT_BATCHED BBMOD_SHADER_DEFAULT

/// @macro {Struct.BBMOD_BaseShader} Depth shader for static models.
/// @deprecated Please use {@link BBMOD_SHADER_DEFAULT_DEPTH} instead.
#macro BBMOD_SHADER_DEPTH BBMOD_SHADER_DEFAULT_DEPTH

/// @macro {Struct.BBMOD_BaseShader} Depth shader for animated models with bones.
/// @deprecated Please use {@link BBMOD_SHADER_DEFAULT_DEPTH} instead.
#macro BBMOD_SHADER_DEPTH_ANIMATED BBMOD_SHADER_DEFAULT_DEPTH

/// @macro {Struct.BBMOD_BaseShader} Depth shader for dynamically batched models.
/// @deprecated Please use {@link BBMOD_SHADER_DEFAULT_DEPTH} instead.
#macro BBMOD_SHADER_DEPTH_BATCHED BBMOD_SHADER_DEFAULT_DEPTH

/// @macro {Struct.BBMOD_BaseShader} Depth shader for lightmapped models with
/// two UV channels.
/// @deprecated Please use {@link BBMOD_SHADER_DEFAULT_DEPTH} instead.
#macro BBMOD_SHADER_LIGHTMAP_DEPTH BBMOD_SHADER_DEFAULT_DEPTH

/// @macro {Struct.BBMOD_LightmapShader} Shader for rendering lightmapped models
/// with two UV channels.
/// @deprecated Please use {@link BBMOD_SHADER_DEFAULT_LIGHTMAP} instead.
#macro BBMOD_SHADER_LIGHTMAP BBMOD_SHADER_DEFAULT_LIGHTMAP

/// @macro {Struct.BBMOD_DefaultSpriteShader} Shader for 2D sprites.
/// @deprecated Please use {@link BBMOD_SHADER_DEFAULT_SPRITE} instead.
#macro BBMOD_SHADER_SPRITE BBMOD_SHADER_DEFAULT_SPRITE

/// @macro {Struct.BBMOD_DefaultMaterial} The default material for animated
/// models.
/// @deprecated Please use {@link BBMOD_MATERIAL_DEFAULT} instead.
#macro BBMOD_MATERIAL_DEFAULT_ANIMATED BBMOD_MATERIAL_DEFAULT

/// @macro {Struct.BBMOD_DefaultMaterial} The default material for dynamically
/// batched models.
/// @see BBMOD_DynamicBatch
/// @deprecated Please use {@link BBMOD_MATERIAL_DEFAULT} instead.
#macro BBMOD_MATERIAL_DEFAULT_BATCHED BBMOD_MATERIAL_DEFAULT

/// @macro {Struct.BBMOD_LightmapMaterial} Material for lightmapped models with
/// two UV channels.
/// @deprecated Please use {@link BBMOD_MATERIAL_DEFAULT_LIGHTMAP} instead.
#macro BBMOD_MATERIAL_LIGHTMAP BBMOD_MATERIAL_DEFAULT_LIGHTMAP

/// @macro {Struct.BBMOD_DefaultMaterial} Material for 2D sprites.
/// @deprecated Please use {@link BBMOD_MATERIAL_DEFAULT_SPRITE} instead.
#macro BBMOD_MATERIAL_SPRITE BBMOD_MATERIAL_DEFAULT_SPRITE

bbmod_shader_register("BBMOD_SHADER_DEPTH",            BBMOD_SHADER_DEPTH);
bbmod_shader_register("BBMOD_SHADER_DEPTH_ANIMATED",   BBMOD_SHADER_DEPTH_ANIMATED);
bbmod_shader_register("BBMOD_SHADER_DEPTH_BATCHED",    BBMOD_SHADER_DEPTH_BATCHED);
bbmod_shader_register("BBMOD_SHADER_LIGHTMAP",         BBMOD_SHADER_LIGHTMAP);
bbmod_shader_register("BBMOD_SHADER_LIGHTMAP_DEPTH",   BBMOD_SHADER_LIGHTMAP_DEPTH);
bbmod_shader_register("BBMOD_SHADER_SPRITE",           BBMOD_SHADER_SPRITE);
bbmod_shader_register("BBMOD_SHADER_DEFAULT_ANIMATED", BBMOD_SHADER_DEFAULT_ANIMATED);
bbmod_shader_register("BBMOD_SHADER_DEFAULT_BATCHED",  BBMOD_SHADER_DEFAULT_BATCHED);

bbmod_material_register("BBMOD_MATERIAL_DEFAULT_ANIMATED", BBMOD_MATERIAL_DEFAULT_ANIMATED);
bbmod_material_register("BBMOD_MATERIAL_DEFAULT_BATCHED",  BBMOD_MATERIAL_DEFAULT_BATCHED);
bbmod_material_register("BBMOD_MATERIAL_LIGHTMAP",         BBMOD_MATERIAL_LIGHTMAP);
bbmod_material_register("BBMOD_MATERIAL_SPRITE",           BBMOD_MATERIAL_SPRITE);
