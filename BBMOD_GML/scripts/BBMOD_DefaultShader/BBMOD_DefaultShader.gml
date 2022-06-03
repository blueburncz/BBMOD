/// @func BBMOD_DefaultShader(_shader, _vertexFormat)
/// @extends BBMOD_BaseShader
/// @desc Shader used by the default BBMOD materials.
/// @param {Resource.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
/// @see BBMOD_DefaultMaterial
function BBMOD_DefaultShader(_shader, _vertexFormat)
	: BBMOD_BaseShader(_shader, _vertexFormat) constructor
{
	static Super_BaseShader = {
		on_set: on_set,
		set_material: set_material,
	};

	UNormalSmoothness = get_sampler_index("bbmod_NormalSmoothness");

	USpecularColor = get_sampler_index("bbmod_SpecularColor");

	/// @func set_normal_smoothness(_texture)
	/// @desc Sets the `bbmod_NormalSmoothness` uniform.
	/// @param {Pointer.Texture} _texture The new texture with normal vector in
	/// the RGB channels and smoothness in the A channel.
	/// @return {Struct.BBMOD_DefaultShader} Returns `self`.
	static set_normal_smoothness = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(UNormalSmoothness, _texture);
	};

	/// @func set_specular_color(_texture)
	/// @desc Sets the `bbmod_SpecularColor` uniform.
	/// @param {Pointer.Texture} _texture The new texture with specular color in
	/// the RGB channels.
	/// @return {Struct.BBMOD_DefaultShader} Returns `self`.
	static set_specular_color = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(USpecularColor, _texture);
	};

	static set_material = function (_material) {
		gml_pragma("forceinline");
		method(self, Super_BaseShader.set_material)(_material);
		set_normal_smoothness(_material.NormalSmoothness);
		set_specular_color(_material.SpecularColor);
		return self;
	};
}
