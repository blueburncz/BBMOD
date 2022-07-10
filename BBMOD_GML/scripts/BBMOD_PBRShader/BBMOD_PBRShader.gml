/// @func BBMOD_PBRShader(_shader, _vertexFormat)
///
/// @extends BBMOD_DefaultShader
///
/// @desc A wrapper for a raw GameMaker shader resource using PBR.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
///
/// @obsolete Please use {@link BBMOD_DefaultShader} instead.
function BBMOD_PBRShader(_shader, _vertexFormat)
	: BBMOD_DefaultShader(_shader, _vertexFormat) constructor
{
}
