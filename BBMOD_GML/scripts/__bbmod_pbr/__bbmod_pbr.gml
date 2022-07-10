/// @macro {Struct.BBMOD_PBRShader} PBR shader for static models.
/// @see BBMOD_PBRShader
/// @obsolete Please use {@link BBMOD_SHADER_DEFAULT} instead.
#macro BBMOD_SHADER_PBR __bbmod_shader_pbr()

/// @macro {Struct.BBMOD_PBRShader} PBR shader for animated models with bones.
/// @see BBMOD_PBRShader
/// @obsolete Please use {@link BBMOD_SHADER_DEFAULT_ANIMATED} instead.
#macro BBMOD_SHADER_PBR_ANIMATED __bbmod_shader_pbr_animated()

/// @macro {Struct.BBMOD_PBRShader} PBR shader for dynamically batched models.
/// @see BBMOD_PBRShader
/// @see BBMOD_DynamicBatch
/// @obsolete Please use {@link BBMOD_SHADER_BATCHED} instead.
#macro BBMOD_SHADER_PBR_BATCHED __bbmod_shader_pbr_batched()

/// @macro {Struct.BBMOD_PBRMaterial} PBR material for static models.
/// @see BBMOD_PBRMaterial
/// @obsolete Please use {@link BBMOD_MATERIAL_DEFAULT} instead.
#macro BBMOD_MATERIAL_PBR __bbmod_material_pbr()

/// @macro {Struct.BBMOD_PBRMaterial} PBR material for animated models with
/// bones.
/// @see BBMOD_PBRMaterial
/// @obsolete Please use {@link BBMOD_MATERIAL_DEFAULT_ANIMATED} instead.
#macro BBMOD_MATERIAL_PBR_ANIMATED __bbmod_material_pbr_animated()

/// @macro {Struct.BBMOD_PBRMaterial} PBR material for dynamically batched
/// models.
/// @see BBMOD_PBRMaterial
/// @see BBMOD_DynamicBatch
/// @obsolete Please use {@link BBMOD_MATERIAL_DEFAULT_BATCHED} instead.
#macro BBMOD_MATERIAL_PBR_BATCHED __bbmod_material_pbr_batched()

function __bbmod_shader_pbr()
{
	gml_pragma("forceinline");
	return __bbmod_shader_default();
}

function __bbmod_shader_pbr_animated()
{
	gml_pragma("forceinline");
	return __bbmod_shader_default_animated();
}

function __bbmod_shader_pbr_batched()
{
	gml_pragma("forceinline");
	return __bbmod_shader_default_batched();
}

function __bbmod_material_pbr()
{
	gml_pragma("forceinline");
	return __bbmod_material_default();
}

function __bbmod_material_pbr_animated()
{
	gml_pragma("forceinline");
	return __bbmod_material_default_animated();
}

function __bbmod_material_pbr_batched()
{
	gml_pragma("forceinline");
	return __bbmod_material_default_batched();
}
