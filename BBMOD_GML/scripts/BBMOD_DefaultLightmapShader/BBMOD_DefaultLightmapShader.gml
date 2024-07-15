/// @module Core

/// @func BBMOD_DefaultLightmapShader(_shader, _vertexFormat)
///
/// @extends BBMOD_DefaultShader
///
/// @desc Shader used by lightmapped materials.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
///
/// @see BBMOD_LightmapMaterial
function BBMOD_DefaultLightmapShader(_shader, _vertexFormat)
	: BBMOD_DefaultShader(_shader, _vertexFormat) constructor
{
	static DefaultShader_on_set = on_set;
	static DefaultShader_set_material = set_material;

	static set_ibl = function (_ibl=undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_ibl(shader_current(), _ibl, true);
		return self;
	};

	static set_ambient_light = function (_up=undefined, _down=undefined, _dir=undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_ambient_light(shader_current(), _up, _down, _dir, true);
		return self;
	};

	static set_directional_light = function (_light=undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_directional_light(shader_current(), _light, true);
		return self;
	};

	static set_punctual_lights = function (_lights=undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_punctual_lights(shader_current(), _lights, true);
		return self;
	};

	/// @func set_lightmap(_texture)
	///
	/// @desc Sets the {@link BBMOD_U_LIGHTMAP} uniform.
	///
	/// @param {Pointer.Texture} [_texture] The new RGBM encoded lightmap
	/// texture. If not specified, defaults to the one configured using
	/// {@link bbmod_lightmap_set}.
	///
	/// @return {Struct.BBMOD_DefaultLightmapShader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_lightmap} instead.
	static set_lightmap = function (_texture=bbmod_lightmap_get())
	{
		gml_pragma("forceinline");
		bbmod_shader_set_lightmap(shader_current(), _texture);
		return self;
	};

	static on_set = function ()
	{
		DefaultShader_on_set();
		bbmod_shader_set_lightmap(shader_current());
		return self;
	};

	static set_material = function (_material)
	{
		gml_pragma("forceinline");
		DefaultShader_set_material(_material);
		if (_material.Lightmap != undefined)
		{
			bbmod_shader_set_lightmap(shader_current(), _material.Lightmap);
		}
		return self;
	};
}

/// @func bbmod_lightmap_get()
///
/// @desc Retrieves the default lightmap texture used by all lightmapped
/// materials in the current scene.
///
/// @return {Pointer.Texture} The default RGBM encoded lightmap texture.
///
/// @deprecated Please use {@link BBMOD_Scene.Lightmap} instead.
function bbmod_lightmap_get()
{
	gml_pragma("forceinline");
	return bbmod_scene_get_current().Lightmap;
}

/// @func bbmod_lightmap_set(_texture)
///
/// @desc Changes the default lightmap texture used by all lightmapped
/// materials in the current scene.
///
/// @param {Pointer.Texture} _texture The new default RGBM encoded lightmap
/// texture.
///
/// @deprecated Please use {@link BBMOD_Scene.Lightmap} instead.
function bbmod_lightmap_set(_texture)
{
	gml_pragma("forceinline");
	bbmod_scene_get_current().Lightmap = _texture;
}
