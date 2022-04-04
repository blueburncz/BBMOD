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

	UIBL = get_sampler_index("bbmod_IBL");

	UIBLTexel = get_uniform("bbmod_IBLTexel");

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

	/// @func set_ibl([_ibl])
	/// @desc Sets a fragment shader uniform `bbmod_IBLTexel` and samplers
	/// `bbmod_IBL` and `bbmod_BRDF`. These are required for image based
	/// lighting.
	/// @param {Struct.BBMOD_ImageBasedLight/Undefined} [_ibl] The image based light.
	/// If `undefined`, then the value set by {@link bbmod_ibl_set} is used. If
	/// the light is not enabled, then it is not passed.
	/// @return {Struct.BBMOD_PBRShader} Returns `self`.
	static set_ibl = function (_ibl=undefined) {
		gml_pragma("forceinline");

		static _iblNull = sprite_get_texture(BBMOD_SprIBLNull, 0);
		var _texture = _iblNull;
		var _texel = 0.0;

		_ibl ??= global.__bbmodImageBasedLight;
		if (_ibl != undefined && _ibl.Enabled)
		{
			_texture = _ibl.Texture;
			_texel = _ibl.Texel;
		}

		gpu_set_tex_mip_enable_ext(UIBL, mip_off);
		gpu_set_tex_filter_ext(UIBL, true);
		gpu_set_tex_repeat_ext(UIBL, false);
		set_sampler(UIBL, _texture);
		set_uniform_f(UIBLTexel, _texel, _texel);

		return self;
	};

	static on_set = function () {
		gml_pragma("forceinline");
		method(self, Super_BaseShader.on_set)();
		set_ibl();
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