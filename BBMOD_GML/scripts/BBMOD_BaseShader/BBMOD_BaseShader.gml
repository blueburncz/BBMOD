/// @module Core

/// @func BBMOD_BaseShader(_shader, _vertexFormat)
///
/// @extends BBMOD_Shader
///
/// @desc Base struct for BBMOD shaders.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
///
/// @see BBMOD_Shader
///
/// @deprecated This struct is obsolete. Please use {@link BBMOD_Shader}
/// instead. All properties and methods previously in BBMOD_BaseShader are now
/// available directly in BBMOD_Shader.
function BBMOD_BaseShader(_shader, _vertexFormat): BBMOD_Shader(_shader, _vertexFormat) constructor {}
