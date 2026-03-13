/// @module Core

/// @func BBMOD_TerrainShader()
///
/// @extends BBMOD_Shader
///
/// @desc Base struct for BBMOD terrain shaders.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
///
/// @see BBMOD_Shader
///
/// @deprecated This struct is obsolete. Please use {@link BBMOD_Shader}
/// instead. All properties and methods previously in BBMOD_TerrainShader are
/// now available directly in BBMOD_Shader.
function BBMOD_TerrainShader(_shader, _vertexFormat): BBMOD_Shader(_shader, _vertexFormat) constructor {}
