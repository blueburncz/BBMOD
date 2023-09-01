/// @module Terrain

/// @func BBMOD_TerrainShader()
///
/// @extends BBMOD_BaseShader
///
/// @desc Base class for BBMOD terrain shaders.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
function BBMOD_TerrainShader(_shader, _vertexFormat)
	: BBMOD_BaseShader(_shader, _vertexFormat) constructor
{
	/// @var {Real} Number of terrain layers that this shader can render in
	/// a single draw call. Default value is 1. Hard maximum is 3 because of
	/// limited number of texture samplers.
	/// @readonly
	LayersPerDrawCall = 1;

	/// @var {Real} Maximum number of terrain layers that this shader supports.
	/// Default value is 5.
	/// @readonly
	MaxLayers = 5;
}
