/// @macro {Struct.BBMOD_VertexFormat} Vertex format of 2D sprites.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_SPRITE __bbmod_vformat_sprite()

/// @macro {Struct.BBMOD_DefaultSpriteShader} Shader for 2D sprites.
/// @see BBMOD_DefaultSpriteShader
#macro BBMOD_SHADER_SPRITE __bbmod_shader_sprite()

/// @macro {Struct.BBMOD_DefaultMaterial} Material for 2D sprites.
/// @see BBMOD_DefaultMaterial
#macro BBMOD_MATERIAL_SPRITE __bbmod_material_sprite()

function __bbmod_vformat_sprite()
{
	static _vformat = new BBMOD_VertexFormat(
		true, false, true, true, false, false, false);
	return _vformat;
}

function __bbmod_shader_sprite()
{
	static _shader = new BBMOD_DefaultSpriteShader(
		BBMOD_ShSprite, BBMOD_VFORMAT_SPRITE)
	return _shader;
}

function __bbmod_material_sprite()
{
	static _material = new BBMOD_DefaultMaterial(BBMOD_SHADER_SPRITE);
	return _material;
}

bbmod_shader_register("BBMOD_SHADER_SPRITE", BBMOD_SHADER_SPRITE);

bbmod_material_register("BBMOD_MATERIAL_SPRITE", BBMOD_MATERIAL_SPRITE);
