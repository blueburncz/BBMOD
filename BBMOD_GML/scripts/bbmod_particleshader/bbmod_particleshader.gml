/// @module Particles

/// @func BBMOD_ParticleShader(_shader, _vertexFormat)
///
/// @extends BBMOD_DefaultShader
///
/// @desc Shader used by particle materials.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
///
/// @see BBMOD_ParticleMaterial
function BBMOD_ParticleShader(_shader, _vertexFormat)
	: BBMOD_DefaultShader(_shader, _vertexFormat) constructor
{
	static DefaultShader_set_material = set_material;

	static set_material = function (_material)
	{
		gml_pragma("forceinline");
		DefaultShader_set_material(_material);
		bbmod_shader_set_soft_distance(shader_current(), _material.SoftDistance);
		return self;
	};
}
