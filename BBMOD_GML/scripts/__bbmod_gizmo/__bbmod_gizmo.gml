/// @macro {Struct.BBMOD_BaseShader}
#macro BBMOD_SHADER_ID __bbmod_shader_id()

/// @macro {Struct.BBMOD_BaseShader}
#macro BBMOD_SHADER_ID_ANIMATED __bbmod_shader_id_animated()

function __bbmod_shader_id()
{
	static _shader = new BBMOD_BaseShader(BBMOD_ShID, BBMOD_VFORMAT_DEFAULT);
	return _shader;
}

function __bbmod_shader_id_animated()
{
	static _shader = new BBMOD_BaseShader(BBMOD_ShIDAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED);
	return _shader;
}
