/// @module Gizmo

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
///
/// @example
/// ```gml
/// material = BBMOD_MATERIAL_DEFAULT.clone()
///     .set_shader(BBMOD_ERenderPass.Id, BBMOD_SHADER_INSTANCE_ID);
/// ```
///
/// @see BBMOD_ERenderPass.Id
#macro BBMOD_SHADER_INSTANCE_ID __bbmod_shader_id()

function __bbmod_shader_id()
{
	static _shader = new BBMOD_BaseShader(BBMOD_ShStatic_InstanceID, BBMOD_VFORMAT_DEFAULT)
		.add_variant(BBMOD_ShAnimated_InstanceID, BBMOD_VFORMAT_DEFAULT_ANIMATED)
		.add_variant(BBMOD_ShBatched_InstanceID, BBMOD_VFORMAT_DEFAULT_BATCHED)
		.add_variant(BBMOD_ShStatic_InstanceID_VertexColors, BBMOD_VFORMAT_DEFAULT_COLOR)
		.add_variant(BBMOD_ShAnimated_InstanceID_VertexColors, BBMOD_VFORMAT_DEFAULT_COLOR_ANIMATED)
		.add_variant(BBMOD_ShBatched_InstanceID_VertexColors, BBMOD_VFORMAT_DEFAULT_COLOR_BATCHED)
		.add_variant(BBMOD_ShLightmapped_InstanceID, BBMOD_VFORMAT_DEFAULT_LIGHTMAP);
	return _shader;
}

////////////////////////////////////////////////////////////////////////////////
// DEPRECATED!!!

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @deprecated Please use {@link BBMOD_SHADER_INSTANCE_ID} instead.
#macro BBMOD_SHADER_INSTANCE_ID_ANIMATED BBMOD_SHADER_INSTANCE_ID

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @deprecated Please use {@link BBMOD_SHADER_INSTANCE_ID} instead.
#macro BBMOD_SHADER_INSTANCE_ID_BATCHED BBMOD_SHADER_INSTANCE_ID

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs
/// for lightmapped models.
/// @deprecated Please use {@link BBMOD_SHADER_INSTANCE_ID} instead.
#macro BBMOD_SHADER_LIGHTMAP_INSTANCE_ID BBMOD_SHADER_INSTANCE_ID

bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID", BBMOD_SHADER_INSTANCE_ID);
bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID_ANIMATED", BBMOD_SHADER_INSTANCE_ID_ANIMATED);
bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID_BATCHED", BBMOD_SHADER_INSTANCE_ID_BATCHED);
bbmod_shader_register("BBMOD_SHADER_LIGHTMAP_INSTANCE_ID", BBMOD_SHADER_LIGHTMAP_INSTANCE_ID);
