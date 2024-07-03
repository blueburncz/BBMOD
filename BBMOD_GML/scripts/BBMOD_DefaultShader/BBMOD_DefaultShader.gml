/// @module Core

/// @func BBMOD_DefaultShader(_shader, _vertexFormat)
///
/// @extends BBMOD_BaseShader
///
/// @desc Shader used by the default BBMOD materials.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
///
/// @see BBMOD_DefaultMaterial
function BBMOD_DefaultShader(_shader, _vertexFormat)
	: BBMOD_BaseShader(_shader, _vertexFormat) constructor
{
	static BaseShader_set_material = set_material;

	/// @func set_normal_smoothness(_texture)
	///
	/// @desc Sets uniforms {@link BBMOD_U_NORMAL_W} and {@link BBMOD_U_IS_ROUGHNESS}.
	///
	/// @param {Pointer.Texture} _texture The new texture with normal vector in
	/// the RGB channels and smoothness in the A channel.
	///
	/// @return {Struct.BBMOD_DefaultShader} Returns `self`.
	///
	/// @obsolete Please use {@link bbmod_shader_set_normal_smoothness} instead.
	static set_normal_smoothness = function (_texture)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_normal_smoothness(shader_current(), _texture);
		return self;
	};

	/// @func set_specular_color(_texture)
	///
	/// @desc Sets uniforms {@link BBMOD_U_MATERIAL} and {@link BBMOD_U_IS_METALLIC}.
	///
	/// @param {Pointer.Texture} _texture The new texture with specular color in
	/// the RGB channels.
	///
	/// @return {Struct.BBMOD_DefaultShader} Returns `self`.
	///
	/// @obsolete Please use {@link bbmod_shader_set_specular_color} instead.
	static set_specular_color = function (_texture)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_specular_color(shader_current(), _texture);
		return self;
	};

	/// @func set_normal_roughness(_texture)
	///
	/// @desc Sets uniforms {@link BBMOD_U_NORMAL_W} and {@link BBMOD_U_IS_ROUGHNESS}.
	///
	/// @param {Pointer.Texture} _texture The new texture with normal vector in
	/// the RGB channels and roughness in the A channel.
	///
	/// @return {Struct.BBMOD_DefaultShader} Returns `self`.
	///
	/// @obsolete Please use {@link bbmod_shader_set_normal_roughness} instead.
	static set_normal_roughness = function (_texture)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_normal_roughness(shader_current(), _texture);
		return self;
	};

	/// @func set_metallic_ao(_texture)
	///
	/// @desc Sets uniforms {@link BBMOD_U_MATERIAL} and {@link BBMOD_U_IS_METALLIC}.
	///
	/// @param {Pointer.Texture} _texture The new texture with metalness in the
	/// R channel and ambient occlusion in the G channel.
	///
	/// @return {Struct.BBMOD_DefaultShader} Returns `self`.
	///
	/// @obsolete Please use {@link bbmod_shader_set_metallic_ao} instead.
	static set_metallic_ao = function (_texture)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_metallic_ao(shader_current(), _texture);
		return self;
	};

	/// @func set_subsurface(_texture)
	///
	/// @desc Sets the {@link BBMOD_U_SUBSURFACE} uniform.
	///
	/// @param {Pointer.Texture} _texture The new texture with subsurface color
	/// in the RGB channels and its intensity in the A channel.
	///
	/// @return {Struct.BBMOD_DefaultShader} Returns `self`.
	///
	/// @obsolete Please use {@link bbmod_shader_set_subsurface} instead.
	static set_subsurface = function (_texture)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_subsurface(shader_current(), _texture);
		return self;
	};

	/// @func set_emissive(_texture)
	///
	/// @desc Sets the {@link BBMOD_U_EMISSIVE} uniform.
	///
	/// @param {Pointer.Texture} _texture The new texture with RGBM encoded
	/// emissive color.
	///
	/// @return {Struct.BBMOD_DefaultShader} Returns `self`.
	///
	/// @obsolete Please use {@link bbmod_shader_set_emissive} instead.
	static set_emissive = function (_texture)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_emissive(shader_current(), _texture);
		return self;
	};

	static set_material = function (_material)
	{
		gml_pragma("forceinline");

		BaseShader_set_material(_material);

		var _shaderCurrent = shader_current();

		// Base opacity UVs
		var _baseOpacity = _material.BaseOpacity;
		if (_baseOpacity != pointer_null)
		{
			bbmod_shader_set_base_opacity_uv(_shaderCurrent, texture_get_uvs(_baseOpacity));
		}

		// Normal smoothness/roughness
		var _normalSmoothness = _material.NormalSmoothness;
		if (_normalSmoothness != undefined)
		{
			bbmod_shader_set_normal_smoothness(_shaderCurrent, _normalSmoothness);
			bbmod_shader_set_normal_w_uv(_shaderCurrent, texture_get_uvs(_normalSmoothness));
		}

		var _normalRoughness = _material.NormalRoughness;
		if (_normalRoughness != undefined)
		{
			bbmod_shader_set_normal_roughness(_shaderCurrent, _normalRoughness);
			bbmod_shader_set_normal_w_uv(_shaderCurrent, texture_get_uvs(_normalSmoothness));
		}

		// Specular color/Metallic and AO
		var _specularColor = _material.SpecularColor;
		if (_specularColor != undefined)
		{
			bbmod_shader_set_specular_color(_shaderCurrent, _specularColor);
			bbmod_shader_set_material_uv(_shaderCurrent, texture_get_uvs(_specularColor));
		}

		var _metallicAO = _material.MetallicAO;
		if (_metallicAO != undefined)
		{
			bbmod_shader_set_metallic_ao(_shaderCurrent, _metallicAO);
			bbmod_shader_set_material_uv(_shaderCurrent, texture_get_uvs(_metallicAO));
		}

		// Subsurface
		var _subsurface = _material.Subsurface;
		bbmod_shader_set_subsurface(_shaderCurrent, _subsurface);
		bbmod_shader_set_subsurface_uv(_shaderCurrent, texture_get_uvs(_subsurface));

		// Emissive
		var _emissive = _material.Emissive;
		bbmod_shader_set_emissive(_shaderCurrent, _emissive);
		bbmod_shader_set_emissive_uv(_shaderCurrent, texture_get_uvs(_emissive));

		return self;
	};
}
