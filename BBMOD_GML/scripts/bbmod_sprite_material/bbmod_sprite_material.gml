/// @macro {BBMOD_VertexFormat} Vertex format of 2D sprites.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_SPRITE __bbmod_vformat_sprite()

/// @macro {BBMOD_DefaultShader} Shader for 2D sprites.
/// @see BBMOD_DefaultShader
#macro BBMOD_SHADER_SPRITE __bbmod_shader_sprite()

/// @macro {BBMOD_DefaultMaterial} Material for 2D sprites.
/// @see BBMOD_DefaultMaterial
#macro BBMOD_MATERIAL_SPRITE __bbmod_material_sprite()

function __bbmod_vformat_sprite()
{
	static _vformat = new BBMOD_VertexFormat(true, false, true, true, false, false, false);
	return _vformat;
}

function __bbmod_shader_sprite()
{
	static _shader = new BBMOD_DefaultShader(BBMOD_ShSprite, BBMOD_VFORMAT_SPRITE)
	return _shader;
}

function __bbmod_material_sprite()
{
	static _material = new BBMOD_DefaultMaterial(BBMOD_SHADER_SPRITE);
	return _material;
}