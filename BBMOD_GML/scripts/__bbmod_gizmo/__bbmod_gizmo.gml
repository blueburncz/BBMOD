/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @see BBMOD_BaseShader
#macro BBMOD_SHADER_INSTANCE_ID __bbmod_shader_id()

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @see BBMOD_BaseShader
#macro BBMOD_SHADER_INSTANCE_ID_ANIMATED __bbmod_shader_id_animated()

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @see BBMOD_BaseShader
#macro BBMOD_SHADER_INSTANCE_ID_BATCHED __bbmod_shader_id_batched()

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs
/// for lightmapped models.
/// @see BBMOD_BaseShader
#macro BBMOD_SHADER_INSTANCE_ID_LIGHTMAP __bbmod_shader_id_lightmap()

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs
/// for lightmapped models.
/// @see BBMOD_BaseShader
/// @obsolete Please use {@link BBMOD_SHADER_INSTANCE_ID_LIGHTMAP} instead.
#macro BBMOD_SHADER_LIGHTMAP_INSTANCE_ID BBMOD_SHADER_INSTANCE_ID_LIGHTMAP

function __bbmod_shader_id()
{
	static _shader = new BBMOD_BaseShader(
		BBMOD_ShInstanceID, BBMOD_VFORMAT_DEFAULT);
	return _shader;
}

function __bbmod_shader_id_animated()
{
	static _shader = new BBMOD_BaseShader(
		BBMOD_ShInstanceIDAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED);
	return _shader;
}

function __bbmod_shader_id_batched()
{
	static _shader = new BBMOD_BaseShader(
		BBMOD_ShInstanceIDBatched, BBMOD_VFORMAT_DEFAULT_BATCHED);
	return _shader;
}

function __bbmod_shader_id_lightmap()
{
	static _shader = new BBMOD_BaseShader(
		BBMOD_ShInstanceIDLightmap, __bbmod_vformat_lightmap);
	return _shader;
}

bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID",          BBMOD_SHADER_INSTANCE_ID);
bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID_ANIMATED", BBMOD_SHADER_INSTANCE_ID_ANIMATED);
bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID_BATCHED",  BBMOD_SHADER_INSTANCE_ID_BATCHED);
bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID_LIGHTMAP", BBMOD_SHADER_INSTANCE_ID_LIGHTMAP);

// Obsolete:
bbmod_shader_register("BBMOD_SHADER_LIGHTMAP_INSTANCE_ID", BBMOD_SHADER_LIGHTMAP_INSTANCE_ID);
