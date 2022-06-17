/// @func BBMOD_PBRShader(_shader, _vertexFormat)
/// @extends BBMOD_BaseShader
/// @desc A wrapper for a raw GameMaker shader resource using PBR.
/// @param {Resource.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
function BBMOD_PBRShader(_shader, _vertexFormat)
	: BBMOD_BaseShader(_shader, _vertexFormat) constructor
{
	static Super_BaseShader = {
		on_set: on_set,
		set_material: set_material,
	};

	UNormalRoughness = get_sampler_index("bbmod_NormalRoughness");

	UMetallicAO = get_sampler_index("bbmod_MetallicAO");

	USubsurface = get_sampler_index("bbmod_Subsurface");

	UEmissive = get_sampler_index("bbmod_Emissive");

	/// @func set_normal_roughness(_texture)
	/// @desc Sets the `bbmod_NormalRoughness` uniform.
	/// @param {Pointer.Texture} _texture The new texture with normal vector in
	/// the RGB channels and roughness in the A channel.
	/// @return {Struct.BBMOD_PBRShader} Returns `self`.
	static set_normal_roughness = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(UNormalRoughness, _texture);
	};

	/// @func set_metallic_ao(_texture)
	/// @desc Sets the `bbmod_MetallicAO` uniform.
	/// @param {Pointer.Texture} _texture The new texture with metalness in the
	/// R channel and ambient occlusion in the G channel.
	/// @return {Struct.BBMOD_PBRShader} Returns `self`.
	static set_metallic_ao = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(UMetallicAO, _texture);
	};

	/// @func set_subsurface(_texture)
	/// @desc Sets the `bbmod_Subsurface` uniform.
	/// @param {Pointer.Texture} _texture The new texture with subsurface color
	/// in the RGB channels and its intensity in the A channel.
	/// @return {Struct.BBMOD_PBRShader} Returns `self`.
	static set_subsurface = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(USubsurface, _texture);
	};

	/// @func set_emissive(_texture)
	/// @desc Sets the `bbmod_Emissive` uniform.
	/// @param {Pointer.Texture} _texture The new RGBM encoded emissive color.
	/// @return {Struct.BBMOD_PBRShader} Returns `self`.
	static set_emissive = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(UEmissive, _texture);
	};

	static set_material = function (_material) {
		gml_pragma("forceinline");
		method(self, Super_BaseShader.set_material)(_material);
		set_metallic_ao(_material.MetallicAO);
		set_normal_roughness(_material.NormalRoughness);
		set_subsurface(_material.Subsurface);
		set_emissive(_material.Emissive);
		return self;
	};
}
