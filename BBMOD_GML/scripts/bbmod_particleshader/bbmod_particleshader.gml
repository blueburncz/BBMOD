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
	static Super_DefaultShader = {
		set_material: set_material,
	};

	USoftDistance = get_uniform("bbmod_SoftDistance");

	static set_material = function (_material) {
		gml_pragma("forceinline");
		method(self, Super_DefaultShader.set_material)(_material);
		set_uniform_f(USoftDistance, _material.SoftDistance);
		return self;
	};
}
