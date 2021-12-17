/// @macro {BBMOD_VertexFormat} The default vertex format for static models.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_DEFAULT __bbmod_vformat_default()

/// @macro {BBMOD_VertexFormat} The default vertex format for animated models.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_DEFAULT_ANIMATED __bbmod_vformat_default_animated()

/// @macro {BBMOD_VertexFormat} The default vertex format for dynamically batched models.
/// @see BBMOD_VertexFormat
/// @see BBMOD_DynamicBatch
#macro BBMOD_VFORMAT_DEFAULT_BATCHED __bbmod_vformat_default_batched()

/// @macro {BBMOD_Shader} The default shader.
/// @see BBMOD_Shader
#macro BBMOD_SHADER_DEFAULT __bbmod_shader_default()

/// @macro {BBMOD_Shader} The default shader for animated models.
/// @see BBMOD_Shader
#macro BBMOD_SHADER_DEFAULT_ANIMATED __bbmod_shader_default_animated()

/// @macro {BBMOD_Shader} The default shader for dynamically batched models.
/// @see BBMOD_Shader
/// @see BBMOD_DynamicBatch
#macro BBMOD_SHADER_DEFAULT_BATCHED __bbmod_shader_default_batched()

/// @macro {BBMOD_Material} The default material.
/// @see BBMOD_Material
#macro BBMOD_MATERIAL_DEFAULT __bbmod_material_default()

/// @macro {BBMOD_Material} The default material for animated models.
/// @see BBMOD_Material
#macro BBMOD_MATERIAL_DEFAULT_ANIMATED __bbmod_material_default_animated()

/// @macro {BBMOD_Material} The default material for dynamically batched models.
/// @see BBMOD_Material
/// @see BBMOD_DynamicBatch
#macro BBMOD_MATERIAL_DEFAULT_BATCHED __bbmod_material_default_batched()

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
	static _shader = new BBMOD_DefaultShader(BBMOD_ShDefault, BBMOD_VFORMAT_DEFAULT);
	return _shader;
}

function __bbmod_shader_default_animated()
{
	static _shader = new BBMOD_DefaultShader(BBMOD_ShDefaultAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED);
	return _shader;
}

function __bbmod_shader_default_batched()
{
	static _shader = new BBMOD_DefaultShader(BBMOD_ShDefaultBatched, BBMOD_VFORMAT_DEFAULT_BATCHED);
	return _shader;
}

function __bbmod_material_default()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_DefaultMaterial(BBMOD_SHADER_DEFAULT);
		_material.BaseOpacity = sprite_get_texture(BBMOD_SprCheckerboard, 0);
	}
	return _material;
}

function __bbmod_material_default_animated()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_DefaultMaterial(BBMOD_SHADER_DEFAULT_ANIMATED);
		_material.BaseOpacity = sprite_get_texture(BBMOD_SprCheckerboard, 0);
	}
	return _material;
}

function __bbmod_material_default_batched()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_DefaultMaterial(BBMOD_SHADER_DEFAULT_BATCHED);
		_material.BaseOpacity = sprite_get_texture(BBMOD_SprCheckerboard, 0);
	}
	return _material;
}