/// @module Rendering

/// @func BBMOD_DefaultShader(_shader, _vertexFormat)
///
/// @extends BBMOD_Shader
///
/// @desc Shader used by the default BBMOD materials.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
///
/// @see BBMOD_Shader
///
/// @deprecated This struct is obsolete. Please use {@link BBMOD_Shader}
/// instead. All properties and methods previously in BBMOD_DefaultShader are
/// now available directly in BBMOD_Shader.
function BBMOD_DefaultShader(_shader, _vertexFormat): BBMOD_Shader(_shader, _vertexFormat) constructor {}
