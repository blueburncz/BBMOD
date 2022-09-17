/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @see BBMOD_BaseShader
#macro BBMOD_SHADER_INSTANCE_ID __bbmod_shader_id()

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @see BBMOD_BaseShader
#macro BBMOD_SHADER_INSTANCE_ID_ANIMATED __bbmod_shader_id_animated()

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

bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID", BBMOD_SHADER_INSTANCE_ID);
bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID_ANIMATED", BBMOD_SHADER_INSTANCE_ID_ANIMATED);
