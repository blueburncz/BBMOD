function __bbmod_vformat_default()
{
	static _vformat = new BBMOD_VertexFormat(true, true, true, false, true, false, false);
	return _vformat;
}

function __bbmod_vformat_default_animated()
{
	static _vformat = new BBMOD_VertexFormat(true, true, true, false, true, true, false);
	return _vformat;
}

function __bbmod_vformat_default_batched()
{
	static _vformat = new BBMOD_VertexFormat(true, true, true, false, true, false, true);
	return _vformat;
}

function __bbmod_shader_default()
{
	static _shader = new BBMOD_Shader(BBMOD_ShDefault, BBMOD_VFORMAT_DEFAULT);
	return _shader;
}

function __bbmod_shader_default_animated()
{
	static _shader = new BBMOD_Shader(BBMOD_ShDefaultAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED);
	return _shader;
}

function __bbmod_shader_default_batched()
{
	static _shader = new BBMOD_Shader(BBMOD_ShDefaultAnimated, BBMOD_VFORMAT_DEFAULT_BATCHED);
	return _shader;
}

function __bbmod_material_default()
{
	static _material = new BBMOD_Material(BBMOD_SHADER_DEFAULT);
	return _material;
}

function __bbmod_material_default_animated()
{
	static _material = new BBMOD_Material(BBMOD_SHADER_DEFAULT_ANIMATED);
	return _material;
}

function __bbmod_material_default_batched()
{
	static _material = new BBMOD_Material(BBMOD_SHADER_DEFAULT_BATCHED);
	return _material;
}