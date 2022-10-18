/// @func BBMOD_LightmapShader(_shader, _vertexFormat)
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
function BBMOD_LightmapShader(_shader, _vertexFormat)
	: BBMOD_DefaultShader(_shader, _vertexFormat) constructor
{
	static DefaultShader_on_set = on_set;
	static DefaultShader_set_material = set_material;

	ULightmap = get_sampler_index("bbmod_Lightmap");

	static set_ibl = function (_ibl=undefined) {
		gml_pragma("forceinline");

		static _iblNull = sprite_get_texture(BBMOD_SprBlack, 0);
		var _texture = _iblNull;
		var _texel = 0.0;

		_ibl ??= global.__bbmodImageBasedLight;
		if (_ibl != undefined
			&& _ibl.Enabled
			&& _ibl.AffectLightmaps)
		{
			_texture = _ibl.Texture;
			_texel = _ibl.Texel;
		}

		texture_set_stage(UIBL, _texture);
		gpu_set_tex_mip_enable_ext(UIBL, mip_off);
		gpu_set_tex_filter_ext(UIBL, true);
		gpu_set_tex_repeat_ext(UIBL, false);
		shader_set_uniform_f(UIBLTexel, _texel, _texel)

		return self;
	};

	static set_ambient_light = function (_up=undefined, _down=undefined) {
		gml_pragma("forceinline");
		if (global.__bbmodAmbientAffectLightmap)
		{
			_up ??= global.__bbmodAmbientLightUp;
			_down ??= global.__bbmodAmbientLightDown;
			shader_set_uniform_f(ULightAmbientUp,
				_up.Red / 255.0, _up.Green / 255.0, _up.Blue / 255.0, _up.Alpha);
			shader_set_uniform_f(ULightAmbientDown,
				_down.Red / 255.0, _down.Green / 255.0, _down.Blue / 255.0, _down.Alpha);
		}
		else
		{
			shader_set_uniform_f(ULightAmbientUp, 0.0, 0.0, 0.0, 0.0);
			shader_set_uniform_f(ULightAmbientDown, 0.0, 0.0, 0.0, 0.0);
		}
		return self;
	};

	static set_directional_light = function (_light=undefined) {
		gml_pragma("forceinline");
		_light ??= global.__bbmodDirectionalLight;
		if (_light != undefined
			&& _light.Enabled
			&& _light.AffectLightmaps)
		{
			var _direction = _light.Direction;
			shader_set_uniform_f(ULightDirectionalDir,
				_direction.X, _direction.Y, _direction.Z);
			var _color = _light.Color;
			shader_set_uniform_f(ULightDirectionalColor,
				_color.Red / 255.0,
				_color.Green / 255.0,
				_color.Blue / 255.0,
				_color.Alpha);
		}
		else
		{
			shader_set_uniform_f(ULightDirectionalDir, 0.0, 0.0, -1.0);
			shader_set_uniform_f(ULightDirectionalColor, 0.0, 0.0, 0.0, 0.0);
		}
		return self;
	};

	static set_punctual_lights = function (_lights=undefined) {
		gml_pragma("forceinline");
		_lights ??= global.__bbmodPointLights;
		var _maxLights = MaxPunctualLights;
		var _index = 0;
		var _indexMax = _maxLights * 8;
		var _data = array_create(_indexMax, 0.0);
		var i = 0;
		repeat (array_length(_lights))
		{
			var _light = _lights[i++];
			if (_light.Enabled
				&& _light.AffectLightmaps)
			{
				_light.Position.ToArray(_data, _index);
				_data[@ _index + 3] = _light.Range;
				var _color = _light.Color;
				_data[@ _index + 4] = _color.Red / 255.0;
				_data[@ _index + 5] = _color.Green / 255.0;
				_data[@ _index + 6] = _color.Blue / 255.0;
				_data[@ _index + 7] = _color.Alpha;
				_index += 8;
				if (_index >= _indexMax)
				{
					break;
				}
			}
		}
		shader_set_uniform_f_array(ULightPunctualData, _data);
		return self;
	};

	/// @func set_lightmap(_texture)
	///
	/// @desc Sets the `bbmod_Lightmap` uniform.
	///
	/// @param {Pointer.Texture} [_texture] The new RGBM encoded lightmap
	/// texture. If not specified, defaults to the one configured using
	/// {@link bbmod_lightmap_set}.
	///
	/// @return {Struct.BBMOD_LightmapShader} Returns `self`.
	static set_lightmap = function (_texture=global.__bbmodLightmap) {
		gml_pragma("forceinline");
		texture_set_stage(ULightmap, _texture);
		gpu_set_tex_mip_enable_ext(ULightmap, mip_off);
		gpu_set_tex_filter_ext(ULightmap, true);
		return self;
	};

	static on_set = function () {
		DefaultShader_on_set();
		set_lightmap();
		return self;
	};

	static set_material = function (_material) {
		gml_pragma("forceinline");
		DefaultShader_set_material(_material);
		if (_material.Lightmap != undefined)
		{
			set_lightmap(_material.Lightmap);
		}
		return self;
	};
}

/// @var {Pointer.Texture}
/// @private
global.__bbmodLightmap = sprite_get_texture(BBMOD_SprBlack, 0);

/// @func bbmod_lightmap_get()
///
/// @desc Retrieves the default lightmap texture used by all lightmapped
/// materials.
///
/// @return {Pointer.Texture} The default RGBM encoded lightmap texture.
function bbmod_lightmap_get()
{
	gml_pragma("forceinline");
	return global.__bbmodLightmap;
}

/// @func bbmod_lightmap_set(_texture)
///
/// @desc Changes the default lightmap texture used by all lightmapped
/// materials.
///
/// @param {Pointer.Texture} _texture The new default RGBM encoded lightmap
/// texture.
function bbmod_lightmap_set(_texture)
{
	gml_pragma("forceinline");
	global.__bbmodLightmap = _texture;
}
