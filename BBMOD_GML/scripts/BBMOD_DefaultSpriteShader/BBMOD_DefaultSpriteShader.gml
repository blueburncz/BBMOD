/// @module Core

/// @func BBMOD_DefaultSpriteShader(_shader, _vertexFormat)
///
/// @extends BBMOD_DefaultShader
///
/// @desc A variant of {@link BBMOD_DefaultShader} which can be used when
/// rendering GameMaker sprites.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
///
/// @see BBMOD_DefaultMaterial
///
/// @deprecated Please use {@link BBMOD_DefaultShader} instead.
function BBMOD_DefaultSpriteShader(_shader, _vertexFormat): BBMOD_DefaultShader(_shader, _vertexFormat) constructor {}
