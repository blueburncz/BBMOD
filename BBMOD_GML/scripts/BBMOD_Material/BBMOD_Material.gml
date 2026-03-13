/// @module Core

/// @func __bbmod_material_get_map()
///
/// @desc Retrieves a map of registered materials.
///
/// @return {Id.DsMap<String, Struct.BBMOD_Material>} The map of registered
/// materials.
///
/// @private
function __bbmod_material_get_map()
{
	static _map = ds_map_create();
	return _map;
}

/// @func bbmod_material_register(_name, _material)
///
/// @desc Registers a material.
///
/// @param {String} _name The name of the material.
/// @param {Struct.BBMOD_Material} _material The material.
function bbmod_material_register(_name, _material)
{
	gml_pragma("forceinline");
	static _map = __bbmod_material_get_map();
	_map[?  _name] = _material;
	_material.__name = _name;
}

/// @func bbmod_material_exists(_name)
///
/// @desc Checks if there is a material registered under the name.
///
/// @param {String} _name The name of the material.
///
/// @return {Bool} Returns `true` if there is a material registered under the
/// name.
function bbmod_material_exists(_name)
{
	gml_pragma("forceinline");
	static _map = __bbmod_material_get_map();
	return ds_map_exists(_map, _name);
}

/// @func bbmod_material_get(_name)
///
/// @desc Retrieves a material registered under the name.
///
/// @param {String} _name The name of the material.
///
/// @return {Struct.BBMOD_Material} The material or `undefined` if no
/// material registered under the given name exists.
function bbmod_material_get(_name)
{
	gml_pragma("forceinline");
	static _map = __bbmod_material_get_map();
	return _map[?  _name];
}

/// @var {Struct.BBMOD_Material} The currently applied material or `undefined`.
/// @private
global.__bbmodMaterialCurrent = undefined;

/// @func BBMOD_Material([_shader])
///
/// @extends BBMOD_Resource
///
/// @implements {BBMOD_IMaterial}
///
/// @desc Base struct for materials.
///
/// @param {Struct.BBMOD_Shader} [_shader] A shader that the material uses in
/// the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you would
/// like to use {@link BBMOD_Material.set_shader} to specify shaders used in
/// specific render passes.
///
/// @see BBMOD_MaterialPropertyBlock
/// @see BBMOD_Shader
function BBMOD_Material(_shader = undefined): BBMOD_Resource() constructor
{
	static Resource_destroy = destroy;

	/// @var {String} The name under which is this material registered or
	/// `undefined`.
	/// @private
	__name = undefined;

	/// @var {Real} Cached hash value for material configuration.
	/// @private
	__hash = 0;

	/// @var {Bool} If `true`, the material hash needs to be recomputed.
	/// Set to `true` whenever material properties change. Default value is `true`.
	HashDirty = true;

	/// @var {Real} Render passes in which is the material rendered. Defaults
	/// to 0 (no passes).
	/// @readonly
	/// @see BBMOD_ERenderPass
	RenderPass = 0;

	/// @var {Array<Struct.BBMOD_Shader>} Shaders used in specific render passes.
	/// @private
	/// @see BBMOD_Material.set_shader
	/// @see BBMOD_Material.get_shader
	__shaders = array_create(BBMOD_ERenderPass.SIZE, undefined);

	/// @var {Real} The render queue category used by this material. Defaults to
	/// {@link BBMOD_ERenderQueue.Opaque}.
	RenderQueue = BBMOD_ERenderQueue.Opaque;

	/// @var {Function} A function that is executed when the shader is applied.
	/// Must take the material as the first argument. Use `undefined` if you do
	/// not want to execute any function. Defaults to `undefined`.
	///
	/// @note If there is a material property block set, then this is executed
	/// *after* the material property block is applied!
	///
	/// @see BBMOD_MaterialPropertyBlock
	/// @see bbmod_material_props_set
	///
	/// @obsolete This feature is obsolete! You should extend this struct and
	/// and implement a custom `apply` in case you need to emulate the old
	/// behavior.
	OnApply = undefined;

	/// @var {Constant.BlendMode} A blend mode. Default value is `bm_normal`.
	BlendMode = bm_normal;

	/// @var {Constant.CullMode} A culling mode. Default value is
	/// `cull_counterclockwise`.
	Culling = cull_counterclockwise;

	/// @var {Bool} If `true` then models using this material should write to
	/// the depth buffer. Default value is `true`.
	ZWrite = true;

	/// @var {Bool} If `true` then models using this material should be tested
	/// against the depth buffer. Defaults value is `true`.
	ZTest = true;

	/// @var {Constant.CmpFunc} The function used for depth testing when
	/// {@link BBMOD_Material.ZTest} is enabled. Default value is
	/// `cmpfunc_lessequal`.
	ZFunc = cmpfunc_lessequal;

	/// @var {Real} Discard pixels with alpha less than this value. Use values
	/// in range 0..1. Default value is 0.9.
	AlphaTest = 0.9;

	/// @var {Bool} Use `true` to enable alpha blending. This can have negative
	/// effect on performance, therefore it should be used only when necessary.
	/// Default value is `false`.
	AlphaBlend = false;

	/// @var {Real} Use one of the `mip_` constants. Default value is `mip_markedonly`.
	Mipmapping = mip_markedonly;

	/// @var {Real} Defines a bias for which mip level is used. Can be also
	/// negative values to select lower mip levels. E.g. if mip level 2 would be
	/// normally selected and bias was -1, then level 1 would be selected instead
	/// and if it was 1, then level 3 would be selected instead. Default value is
	/// 0.
	MipBias = 0;

	/// @var {Real} The mip filter mode used for the material. Use one of the
	/// `tf_` constants. Default value is `tf_anisotropic`.
	MipFilter = tf_anisotropic;

	/// @var {Real} The minimum mip level used, where 0 is the highest resolution,
	/// 1 is the first mipmap, 2 is the second etc. Default value is 0.
	MipMin = 0;

	/// @var {Real} The maximum mip level used, where 0 is the highest resolution,
	/// 1 is the first mipmap, 2 is the second etc. Default value is 16.
	MipMax = 16;

	/// @var {Real} The maximum level of anisotropy when
	/// {@link BBMOD_Material.MipFilter} is set to `tf_anisotropic`. Must be in
	/// range 1..16. Default value is 16.
	Anisotropy = 16;

	/// @var {Bool} Use `false` to disable linear texture filtering for this
	/// material. Default value is `true`.
	Filtering = true;

	/// @var {Bool} Use `true` to enable texture repeat for this material.
	/// Default value is `false`.
	Repeat = false;

	/// @var {Pointer.Texture} A texture with a base color in the RGB channels
	/// and opacity in the alpha channel.
	BaseOpacity = pointer_null;

	__baseOpacitySprite = undefined;

	/// @var {Struct.BBMOD_Color} Multiplier for base color and opacity.
	/// Default value is white (no tint).
	BaseOpacityMultiplier = BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Vec2} An offset of texture UV coordinates.
	/// Defaults to (0, 0). Controls texture position within texture page.
	TextureOffset = new BBMOD_Vec2(0.0);

	/// @var {Struct.BBMOD_Vec2} A scale of texture UV coordinates.
	/// Defaults to (1, 1). Controls texture size within texture page.
	TextureScale = new BBMOD_Vec2(1.0);

	/// @var {Real} Controls range over which the mesh smoothly transitions
	/// into shadow. Useful for billboarded particles where harsh transition
	/// doesn't look good. Default value is 0 (no smooth transition).
	ShadowmapBias = 0.0;

	/// @var {Bool} Whether the material is two-sided. If true, normal
	/// vectors of backfaces are flipped before shading. Default is `true`.
	TwoSided = true;

	/// @var {Pointer.Texture} A texture with tangent-space normals in RGB
	/// channels and smoothness in alpha channel or `undefined`.
	NormalSmoothness = sprite_get_texture(BBMOD_SprDefaultNormalW, 0);

	__normalSmoothnessSprite = undefined;

	/// @var {Pointer.Texture} A texture with specular color in RGB channels
	/// or `undefined`.
	SpecularColor = sprite_get_texture(BBMOD_SprDefaultSpecularColor, 0);

	__specularColorSprite = undefined;

	/// @var {Pointer.Texture} A texture with tangent-space normals in RGB
	/// channels and roughness in alpha channel or `undefined`.
	NormalRoughness = undefined;

	__normalRoughnessSprite = undefined;

	/// @var {Pointer.Texture} A texture with metallic in red channel and
	/// ambient occlusion in green channel or `undefined`.
	MetallicAO = undefined;

	__metallicAOSprite = undefined;

	/// @var {Pointer.Texture} A texture with subsurface color in RGB
	/// channels and subsurface effect intensity in alpha channel.
	Subsurface = sprite_get_texture(BBMOD_SprBlack, 0);

	__subsurfaceSprite = undefined;

	/// @var {Pointer.Texture} RGBM encoded emissive texture.
	Emissive = sprite_get_texture(BBMOD_SprBlack, 0);

	__emissiveSprite = undefined;

	/// @var {Pointer.Texture} RGBM encoded lightmap texture. Overrides
	/// the default lightmap texture defined with bbmod_lightmap_set.
	Lightmap = undefined;

	/// @var {Real} Distance over which particles smoothly disappear when
	/// getting closer to geometry in the depth buffer. Use values <= 0 to
	/// disable. Default value is 0.
	SoftDistance = 0.0;

	/// @var {Real}
	DitherFadeStart = -1.0;

	/// @var {Real}
	DitherFadeEnd = -1.0;

	/// @func set_normal_smoothness(_normal, _smoothness)
	///
	/// @desc Changes the normal vector and smoothness to a uniform value for
	/// the entire material.
	///
	/// @param {Struct.BBMOD_Vec3} _normal The new normal vector. If you are not
	/// sure what this value should be, use {@link BBMOD_VEC3_UP}.
	/// @param {Real} _smoothness The new smoothness. Use values in range 0..1.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static set_normal_smoothness = function (_normal, _smoothness)
	{
		NormalRoughness = undefined;
		if (__normalRoughnessSprite != undefined)
		{
			sprite_delete(__normalRoughnessSprite);
			__normalRoughnessSprite = undefined;
		}

		if (__normalSmoothnessSprite != undefined)
		{
			sprite_delete(__normalSmoothnessSprite);
		}
		_normal = _normal.Normalize();
		__normalSmoothnessSprite = _make_sprite(
			(_normal.X * 0.5 + 0.5) * 255.0,
			(_normal.Y * 0.5 + 0.5) * 255.0,
			(_normal.Z * 0.5 + 0.5) * 255.0,
			_smoothness
		);
		NormalSmoothness = sprite_get_texture(__normalSmoothnessSprite, 0);
		return self;
	};

	/// @func set_specular_color(_color)
	///
	/// @desc Changes the specular color to a uniform value for the entire
	/// material.
	///
	/// @param {Struct.BBMOD_Color} _color The new specular color.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static set_specular_color = function (_color)
	{
		MetallicAO = undefined;
		if (__metallicAOSprite != undefined)
		{
			sprite_delete(__metallicAOSprite);
			__metallicAOSprite = undefined;
		}

		if (__specularColorSprite != undefined)
		{
			sprite_delete(__specularColorSprite);
		}
		__specularColorSprite = _make_sprite(
			_color.Red,
			_color.Green,
			_color.Blue,
			1.0
		);
		SpecularColor = sprite_get_texture(__specularColorSprite, 0);
		return self;
	};

	/// @func set_normal_roughness(_normal, _roughness)
	///
	/// @desc Changes the normal vector and roughness to a uniform value for the
	/// entire material.
	///
	/// @param {Struct.BBMOD_Vec3} _normal The new normal vector. If you are not
	/// sure what this value should be, use {@link BBMOD_VEC3_UP}.
	/// @param {Real} _roughness The new roughness. Use values in range 0..1.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static set_normal_roughness = function (_normal, _roughness)
	{
		NormalSmoothness = undefined;
		if (__normalSmoothnessSprite != undefined)
		{
			sprite_delete(__normalSmoothnessSprite);
			__normalSmoothnessSprite = undefined;
		}

		if (__normalRoughnessSprite != undefined)
		{
			sprite_delete(__normalRoughnessSprite);
		}
		_normal = _normal.Normalize();
		__normalRoughnessSprite = _make_sprite(
			(_normal.X * 0.5 + 0.5) * 255.0,
			(_normal.Y * 0.5 + 0.5) * 255.0,
			(_normal.Z * 0.5 + 0.5) * 255.0,
			_roughness
		);
		NormalRoughness = sprite_get_texture(__normalRoughnessSprite, 0);
		return self;
	};

	/// @func set_metallic_ao(_metallic, _ao)
	///
	/// @desc Changes the metalness and ambient occlusion to a uniform value for
	/// the entire material.
	///
	/// @param {Real} _metallic The new metalness. You can use any value in range
	/// 0..1, but in general this is usually either 0 for dielectric materials
	/// and 1 for metals.
	/// @param {Real} _ao The new ambient occlusion value. Use values in range
	/// 0..1, where 0 means full occlusion and 1 means no occlusion.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static set_metallic_ao = function (_metallic, _ao)
	{
		SpecularColor = undefined;
		if (__specularColorSprite != undefined)
		{
			sprite_delete(__specularColorSprite);
			__specularColorSprite = undefined;
		}

		if (__metallicAOSprite != undefined)
		{
			sprite_delete(__metallicAOSprite);
		}
		__metallicAOSprite = _make_sprite(
			_metallic * 255.0,
			_ao * 255.0,
			0.0,
			0.0
		);
		MetallicAO = sprite_get_texture(__metallicAOSprite, 0);
		return self;
	};

	/// @func set_subsurface(_color, _intensity)
	///
	/// @desc Changes the subsurface color to a uniform value for the entire
	/// material.
	///
	/// @param {Real} _color The new subsurface color.
	/// @param {Real} _intensity The subsurface color intensity. Use values in
	/// range 0..1. The higher the value, the more visible the effect is.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static set_subsurface = function (_color, _intensity)
	{
		if (__subsurfaceSprite != undefined)
		{
			sprite_delete(__subsurfaceSprite);
		}
		__subsurfaceSprite = _make_sprite(
			color_get_red(_color),
			color_get_green(_color),
			color_get_blue(_color),
			_intensity
		);
		Subsurface = sprite_get_texture(__subsurfaceSprite, 0);
		return self;
	};

	/// @func set_emissive(_color)
	///
	/// @desc Changes the emissive color to a uniform value for the entire
	/// material.
	///
	/// @param {Struct.BBMOD_Color} _color The new emissive color.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static set_emissive = function ()
	{
		var _color = (argument_count == 3)
			? new BBMOD_Color(argument[0], argument[1], argument[2])
			: argument[0];
		var _rgbm = _color.ToRGBM();
		if (__emissiveSprite != undefined)
		{
			sprite_delete(__emissiveSprite);
		}
		__emissiveSprite = _make_sprite(
			_rgbm[0] * 255.0,
			_rgbm[1] * 255.0,
			_rgbm[2] * 255.0,
			_rgbm[3]
		);
		Emissive = sprite_get_texture(__emissiveSprite, 0);
		return self;
	};

	/// @func copy(_dest)
	///
	/// @desc Copies properties of this material into another material.
	///
	/// @param {Struct.BBMOD_Material} _dest The destination material.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static copy = function (_dest)
	{
		_dest.__name = __name;
		_dest.RenderPass = RenderPass;
		_dest.__shaders = array_create(BBMOD_ERenderPass.SIZE, undefined);
		array_copy(_dest.__shaders, 0, __shaders, 0, BBMOD_ERenderPass.SIZE);
		_dest.RenderQueue = RenderQueue;
		_dest.OnApply = OnApply;
		_dest.BlendMode = BlendMode;
		_dest.Culling = Culling;
		_dest.ZWrite = ZWrite;
		_dest.ZTest = ZTest;
		_dest.ZFunc = ZFunc;
		_dest.AlphaTest = AlphaTest;
		_dest.AlphaBlend = AlphaBlend;
		_dest.Mipmapping = Mipmapping;
		_dest.MipBias = MipBias;
		_dest.MipFilter = MipFilter;
		_dest.MipMin = MipMin;
		_dest.MipMax = MipMax;
		_dest.Anisotropy = Anisotropy;
		_dest.Filtering = Filtering;
		_dest.Repeat = Repeat;

		if (_dest.__baseOpacitySprite != undefined)
		{
			sprite_delete(_dest.__baseOpacitySprite);
			_dest.__baseOpacitySprite = undefined;
		}

		if (__baseOpacitySprite != undefined)
		{
			_dest.__baseOpacitySprite = sprite_duplicate(__baseOpacitySprite);
			_dest.BaseOpacity = sprite_get_texture(_dest.__baseOpacitySprite, 0);
		}
		else
		{
			_dest.BaseOpacity = BaseOpacity;
		}

		// BaseMaterial properties
		BaseOpacityMultiplier.Copy(_dest.BaseOpacityMultiplier);
		_dest.TextureOffset = TextureOffset.Clone();
		_dest.TextureScale = TextureScale.Clone();
		_dest.ShadowmapBias = ShadowmapBias;
		_dest.TwoSided = TwoSided;

		// DefaultMaterial NormalSmoothness
		if (_dest.__normalSmoothnessSprite != undefined)
		{
			sprite_delete(_dest.__normalSmoothnessSprite);
			_dest.__normalSmoothnessSprite = undefined;
		}
		if (__normalSmoothnessSprite != undefined)
		{
			_dest.__normalSmoothnessSprite = sprite_duplicate(__normalSmoothnessSprite);
			_dest.NormalSmoothness = sprite_get_texture(_dest.__normalSmoothnessSprite, 0);
		}
		else
		{
			_dest.NormalSmoothness = NormalSmoothness;
		}

		// DefaultMaterial SpecularColor
		if (_dest.__specularColorSprite != undefined)
		{
			sprite_delete(_dest.__specularColorSprite);
			_dest.__specularColorSprite = undefined;
		}
		if (__specularColorSprite != undefined)
		{
			_dest.__specularColorSprite = sprite_duplicate(__specularColorSprite);
			_dest.SpecularColor = sprite_get_texture(_dest.__specularColorSprite, 0);
		}
		else
		{
			_dest.SpecularColor = SpecularColor;
		}

		// DefaultMaterial NormalRoughness
		if (_dest.__normalRoughnessSprite != undefined)
		{
			sprite_delete(_dest.__normalRoughnessSprite);
			_dest.__normalRoughnessSprite = undefined;
		}
		if (__normalRoughnessSprite != undefined)
		{
			_dest.__normalRoughnessSprite = sprite_duplicate(__normalRoughnessSprite);
			_dest.NormalRoughness = sprite_get_texture(_dest.__normalRoughnessSprite, 0);
		}
		else
		{
			_dest.NormalRoughness = NormalRoughness;
		}

		// DefaultMaterial MetallicAO
		if (_dest.__metallicAOSprite != undefined)
		{
			sprite_delete(_dest.__metallicAOSprite);
			_dest.__metallicAOSprite = undefined;
		}
		if (__metallicAOSprite != undefined)
		{
			_dest.__metallicAOSprite = sprite_duplicate(__metallicAOSprite);
			_dest.MetallicAO = sprite_get_texture(_dest.__metallicAOSprite, 0);
		}
		else
		{
			_dest.MetallicAO = MetallicAO;
		}

		// DefaultMaterial Subsurface
		if (_dest.__subsurfaceSprite != undefined)
		{
			sprite_delete(_dest.__subsurfaceSprite);
			_dest.__subsurfaceSprite = undefined;
		}
		if (__subsurfaceSprite != undefined)
		{
			_dest.__subsurfaceSprite = sprite_duplicate(__subsurfaceSprite);
			_dest.Subsurface = sprite_get_texture(_dest.__subsurfaceSprite, 0);
		}
		else
		{
			_dest.Subsurface = Subsurface;
		}

		// DefaultMaterial Emissive
		if (_dest.__emissiveSprite != undefined)
		{
			sprite_delete(_dest.__emissiveSprite);
			_dest.__emissiveSprite = undefined;
		}
		if (__emissiveSprite != undefined)
		{
			_dest.__emissiveSprite = sprite_duplicate(__emissiveSprite);
			_dest.Emissive = sprite_get_texture(_dest.__emissiveSprite, 0);
		}
		else
		{
			_dest.Emissive = Emissive;
		}

		// DefaultLightmapMaterial properties
		_dest.Lightmap = Lightmap;

		// ParticleMaterial properties
		_dest.SoftDistance = SoftDistance;

		// Dithering
		_dest.DitherFadeStart = DitherFadeStart;
		_dest.DitherFadeEnd = DitherFadeEnd;

		// Mark hash as dirty so it will be recomputed
		_dest.HashDirty = true;

		return self;
	};

	/// @func clone()
	///
	/// @desc Creates a clone of the material.
	///
	/// @return {Struct.BBMOD_Material} The created clone.
	static clone = function ()
	{
		var _clone = new BBMOD_Material();
		copy(_clone);
		return _clone;
	};

	/// @func to_json(_json)
	///
	/// @desc Saves material properties to a JSON object.
	///
	/// @param {Struct} _json The object to save the properties to.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If an error occurs.
	static to_json = function (_json)
	{
		var _shaders = {};
		var _pass = 0;
		repeat(BBMOD_ERenderPass.SIZE)
		{
			var _shader = __shaders[_pass];
			if (_shader != undefined)
			{
				var _passName = bbmod_render_pass_to_string(_pass);
				if (_shader.__name == undefined)
				{
					throw new BBMOD_Exception(
						"Cannot save to JSON, shader for render pass \""
						+ _passName + "\" is not registered!");
				}
				else
				{
					_shaders[$  _passName] = _shader.__name;
				}
			}
			++_pass;
		}
		_json.__shaders = _shaders;

		_json.RenderQueue = RenderQueue;

		// TODO: Save OnApply

		_json.BlendMode = BlendMode;
		_json.Culling = Culling;
		_json.ZWrite = ZWrite;
		_json.ZTest = ZTest;
		_json.ZFunc = ZFunc;
		_json.AlphaTest = AlphaTest;
		_json.AlphaBlend = AlphaBlend;
		_json.Mipmapping = Mipmapping;
		_json.MipBias = MipBias;
		_json.MipFilter = MipFilter;
		_json.MipMin = MipMin;
		_json.MipMax = MipMax;
		_json.Anisotropy = Anisotropy;
		_json.Filtering = Filtering;
		_json.Repeat = Repeat;

		// TODO: Save BaseOpacity/__baseOpacitySprite

		// BaseMaterial properties
		_json.BaseOpacityMultiplier = {
			Red: BaseOpacityMultiplier.Red,
			Green: BaseOpacityMultiplier.Green,
			Blue: BaseOpacityMultiplier.Blue,
			Alpha: BaseOpacityMultiplier.Alpha,
		};

		_json.TextureOffset = {
			X: TextureOffset.X,
			Y: TextureOffset.Y,
		};

		_json.TextureScale = {
			X: TextureScale.X,
			Y: TextureScale.Y,
		};

		_json.ShadowmapBias = ShadowmapBias;
		_json.TwoSided = TwoSided;

		// DefaultMaterial properties
		// TODO: Save texture sprites (NormalSmoothness, SpecularColor, etc.)

		// DefaultLightmapMaterial properties
		// TODO: Save Lightmap

		// ParticleMaterial properties
		_json.SoftDistance = SoftDistance;

		// Dithering
		_json.DitherFadeStart = DitherFadeStart;
		_json.DitherFadeEnd = DitherFadeEnd;

		return self;
	};

	/// @func from_json(_json)
	///
	/// @desc Loads material properties from a JSON object.
	///
	/// @param {Struct} _json The object to load the properties from.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If an error occurs.
	static from_json = function (_json)
	{
		if (variable_struct_exists(_json, "Shaders"))
		{
			var _shaders = _json.Shaders;
			var _keys = variable_struct_get_names(_shaders);
			var _index = 0;
			repeat(array_length(_keys))
			{
				var _passName = _keys[_index++];
				var _pass = bbmod_render_pass_from_string(_passName);
				var _shader = _shaders[$  _passName];
				if (is_string(_shader))
				{
					if (_shader == "undefined")
					{
						remove_shader(_pass);
					}
					else
					{
						_shader = bbmod_shader_get(_shader);
						set_shader(_pass, _shader);
					}
				}
				else if (_shader == undefined)
				{
					remove_shader(_pass);
				}
				else
				{
					set_shader(_pass, _shader);
				}
			}
		}

		if (variable_struct_exists(_json, "RenderQueue"))
		{
			var _renderQueue = _json.RenderQueue;
			if (is_string(_renderQueue))
			{
				// Backwards compatibility: convert old string names to enum values
				switch (_renderQueue)
				{
					case "Sky":
						_renderQueue = BBMOD_ERenderQueue.Sky;
						break;
					case "Terrain":
						_renderQueue = BBMOD_ERenderQueue.Terrain;
						break;
					case "Opaque":
					case "Default":
						_renderQueue = BBMOD_ERenderQueue.Opaque;
						break;
					case "Transparent":
						_renderQueue = BBMOD_ERenderQueue.Transparent;
						break;
					default:
						// Unknown queue name, default to Opaque
						_renderQueue = BBMOD_ERenderQueue.Opaque;
						break;
				}
			}
			RenderQueue = _renderQueue;
		}

		if (variable_struct_exists(_json, "OnApply"))
		{
			OnApply = _json.OnApply;
		}

		if (variable_struct_exists(_json, "BlendMode"))
		{
			var _blendMode = _json.BlendMode;
			BlendMode = is_string(_blendMode)
				? bbmod_blendmode_from_string(_blendMode)
				: _blendMode;
		}

		if (variable_struct_exists(_json, "Culling"))
		{
			var _culling = _json.Culling;
			Culling = is_string(_culling)
				? bbmod_cullmode_from_string(_culling)
				: _culling;
		}

		if (variable_struct_exists(_json, "ZWrite"))
		{
			ZWrite = _json.ZWrite;
		}

		if (variable_struct_exists(_json, "ZTest"))
		{
			ZTest = _json.ZTest;
		}

		if (variable_struct_exists(_json, "ZFunc"))
		{
			var _zFunc = _json.ZFunc;
			ZFunc = is_string(_zFunc)
				? bbmod_cmpfunc_from_string(_zFunc)
				: _zFunc;
		}

		if (variable_struct_exists(_json, "AlphaTest"))
		{
			AlphaTest = _json.AlphaTest;
		}

		if (variable_struct_exists(_json, "AlphaBlend"))
		{
			AlphaBlend = _json.AlphaBlend;
		}

		if (variable_struct_exists(_json, "Mipmapping"))
		{
			var _mipmapping = _json.Mipmapping;
			Mipmapping = is_string(_mipmapping)
				? bbmod_mipenable_from_string(_mipmapping)
				: _mipmapping;
		}

		if (variable_struct_exists(_json, "MipBias"))
		{
			MipBias = _json.MipBias;
		}

		if (variable_struct_exists(_json, "MipFilter"))
		{
			var _mipFilter = _json.MipFilter;
			MipFilter = is_string(_mipFilter)
				? bbmod_texfilter_from_string(_mipFilter)
				: _mipFilter;
		}

		if (variable_struct_exists(_json, "MipMin"))
		{
			MipMin = _json.MipMin;
		}

		if (variable_struct_exists(_json, "MipMax"))
		{
			MipMax = _json.MipMax;
		}

		if (variable_struct_exists(_json, "Anisotropy"))
		{
			Anisotropy = _json.Anisotropy;
		}

		if (variable_struct_exists(_json, "Filtering"))
		{
			Filtering = _json.Filtering;
		}

		if (variable_struct_exists(_json, "Repeat"))
		{
			Repeat = _json.Repeat;
		}

		if (variable_struct_exists(_json, "BaseOpacity"))
		{
			if (__baseOpacitySprite != undefined)
			{
				sprite_delete(__baseOpacitySprite);
				__baseOpacitySprite = undefined;
			}

			BaseOpacity = _json.BaseOpacity;
		}

		if (variable_struct_exists(_json, "BaseOpacityMultiplier"))
		{
			var _multiplier = _json.BaseOpacityMultiplier;
			BaseOpacityMultiplier = new BBMOD_Color(
				_multiplier.Red,
				_multiplier.Green,
				_multiplier.Blue,
				_multiplier.Alpha
			);
		}

		if (variable_struct_exists(_json, "TextureOffset"))
		{
			var _offset = _json.TextureOffset;
			TextureOffset = new BBMOD_Vec2(_offset.X, _offset.Y);
		}

		if (variable_struct_exists(_json, "TextureScale"))
		{
			var _scale = _json.TextureScale;
			TextureScale = new BBMOD_Vec2(_scale.X, _scale.Y);
		}

		if (variable_struct_exists(_json, "ShadowmapBias"))
		{
			ShadowmapBias = _json.ShadowmapBias;
		}

		if (variable_struct_exists(_json, "TwoSided"))
		{
			TwoSided = _json.TwoSided;
		}

		if (variable_struct_exists(_json, "NormalSmoothness"))
		{
			if (__normalSmoothnessSprite != undefined)
			{
				sprite_delete(__normalSmoothnessSprite);
				__normalSmoothnessSprite = undefined;
			}

			NormalSmoothness = _json.NormalSmoothness;
		}

		if (variable_struct_exists(_json, "SpecularColor"))
		{
			if (__specularColorSprite != undefined)
			{
				sprite_delete(__specularColorSprite);
				__specularColorSprite = undefined;
			}

			SpecularColor = _json.SpecularColor;
		}

		if (variable_struct_exists(_json, "NormalRoughness"))
		{
			if (__normalRoughnessSprite != undefined)
			{
				sprite_delete(__normalRoughnessSprite);
				__normalRoughnessSprite = undefined;
			}

			NormalRoughness = _json.NormalRoughness;
		}

		if (variable_struct_exists(_json, "MetallicAO"))
		{
			if (__metallicAOSprite != undefined)
			{
				sprite_delete(__metallicAOSprite);
				__metallicAOSprite = undefined;
			}

			MetallicAO = _json.MetallicAO;
		}

		if (variable_struct_exists(_json, "Subsurface"))
		{
			if (__subsurfaceSprite != undefined)
			{
				sprite_delete(__subsurfaceSprite);
				__subsurfaceSprite = undefined;
			}

			Subsurface = _json.Subsurface;
		}

		if (variable_struct_exists(_json, "Emissive"))
		{
			if (__emissiveSprite != undefined)
			{
				sprite_delete(__emissiveSprite);
				__emissiveSprite = undefined;
			}

			Emissive = _json.Emissive;
		}

		if (variable_struct_exists(_json, "Lightmap"))
		{
			Lightmap = _json.Lightmap;
		}

		if (variable_struct_exists(_json, "SoftDistance"))
		{
			SoftDistance = _json.SoftDistance;
		}

		if (variable_struct_exists(_json, "DitherFadeStart"))
		{
			DitherFadeStart = _json.DitherFadeStart;
		}

		if (variable_struct_exists(_json, "DitherFadeEnd"))
		{
			DitherFadeEnd = _json.DitherFadeEnd;
		}

		return self;
	};

	static to_file = function (_file)
	{
		var _dirname = filename_dir(_file);
		if (!directory_exists(_dirname))
		{
			directory_create(_dirname);
		}

		var _json = {};
		to_json(_json);

		var _jsonFile = file_text_open_write(_file);
		file_text_write_string(_jsonFile, json_stringify(_json));
		file_text_close(_jsonFile);

		return self;
	};

	static from_file = function (_file, _sha1 = undefined)
	{
		Path = _file;
		__check_file(_file, _sha1);
		from_json(bbmod_json_load(_file));
		IsLoaded = true;
		return self;
	};

	static from_file_async = function (_file, _sha1 = undefined, _callback = undefined)
	{
		Path = _file;

		if (!__check_file(_file, _sha1, _callback ?? bbmod_empty_callback))
		{
			return self;
		}

		var _json;

		try
		{
			_json = bbmod_json_load(_file);
		}
		catch (_err)
		{
			if (_callback)
			{
				_callback(_err, self);
			}
			return self;
		}

		from_json(_json);
		IsLoaded = true;

		if (_callback != undefined)
		{
			_callback(undefined, self);
		}

		return self;
	};

	static _make_sprite = function (_r, _g, _b, _a)
	{
		gml_pragma("forceinline");
		static _sur = -1;
		_sur = bbmod_surface_check(_sur, 1, 1, surface_rgba8unorm, false);
		surface_set_target(_sur);
		draw_clear_alpha(make_color_rgb(_r, _g, _b), _a);
		surface_reset_target();
		return sprite_create_from_surface(_sur, 0, 0, 1, 1, false, false, 0, 0);
	};

	/// @func set_base_opacity(_color)
	///
	/// @desc Changes the base color and opacity to a uniform value for the
	/// entire material.
	///
	/// @param {Struct.BBMOD_Color} _color The new base color and opacity.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static set_base_opacity = function (_color)
	{
		if (__baseOpacitySprite != undefined)
		{
			sprite_delete(__baseOpacitySprite);
		}
		var _isReal = is_real(_color);
		__baseOpacitySprite = _make_sprite(
			_isReal ? color_get_red(_color) : _color.Red,
			_isReal ? color_get_green(_color) : _color.Green,
			_isReal ? color_get_blue(_color) : _color.Blue,
			_isReal ? argument[1] : _color.Alpha
		);
		BaseOpacity = sprite_get_texture(__baseOpacitySprite, 0);
		return self;
	};

	/// @func apply(_vertexFormat)
	///
	/// @desc Makes this material the current one.
	///
	/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format of
	/// meshes that we are going to use the material for.
	///
	/// @return {Bool} Returns `true` if the material was applied.
	///
	/// @see BBMOD_Material.reset
	static apply = function (_vertexFormat)
	{
		if ((RenderPass & (1 << bbmod_render_pass_get())) == 0)
		{
			return false;
		}

		var _shader = __shaders[bbmod_render_pass_get()];
		var _shaderRaw = _shader.get_variant(_vertexFormat);

		if (_shaderRaw == undefined)
		{
			__bbmod_warning(
				"Shader variant for vertex format "
				+ string(_vertexFormat.get_hash())
				+ " was not found! Material not applied!");
			return false;
		}

		var _shaderChanged = false;
		if (BBMOD_SHADER_CURRENT != _shader
			|| shader_current() != _shaderRaw)
		{
			if (BBMOD_SHADER_CURRENT != undefined)
			{
				BBMOD_SHADER_CURRENT.reset();
			}
			shader_set(_shaderRaw);
			BBMOD_SHADER_CURRENT = _shader;
			_shaderChanged = true;
		}

		if (global.__bbmodMaterialCurrent != self)
		{
			// TODO: GPU settings override per render pass!
			var _renderPass = bbmod_render_pass_get();
			var _disableBlending = (_renderPass == BBMOD_ERenderPass.Shadows
				|| _renderPass == BBMOD_ERenderPass.DepthOnly
				|| _renderPass == BBMOD_ERenderPass.GBuffer
				|| _renderPass == BBMOD_ERenderPass.Id);

			if (global.__bbmodMaterialCurrent != undefined)
			{
				gpu_pop_state();
			}

			gpu_push_state();

			if (_shaderChanged)
			{
				with(_shader)
				{
					on_set();
					bbmod_shader_set_globals(_shaderRaw);
				}
				_shaderChanged = false;
			}

			gpu_set_blendmode(_disableBlending ? bm_normal : BlendMode);
			gpu_set_blendenable(_disableBlending ? false : AlphaBlend);
			gpu_set_cullmode(Culling);
			gpu_set_zwriteenable(ZWrite);
			gpu_set_ztestenable(ZTest);
			gpu_set_zfunc(ZFunc);
			gpu_set_tex_mip_enable(Mipmapping);
			if (Mipmapping)
			{
				gpu_set_tex_mip_bias(MipBias);
				gpu_set_tex_mip_filter(MipFilter);
				gpu_set_tex_min_mip(MipMin);
				gpu_set_tex_max_mip(MipMax);
				gpu_set_tex_max_aniso(Anisotropy);
			}
			gpu_set_tex_filter(Filtering);
			gpu_set_tex_repeat(Repeat);

			_shader.set_material(self);
			global.__bbmodMaterialCurrent = self;
		}

		if (_shaderChanged)
		{
			with(_shader)
			{
				on_set();
				bbmod_shader_set_globals(_shaderRaw);
			}
			_shader.set_material(self);
		}

		return true;
	};

	/// @func set_shader(_pass, _shader)
	///
	/// @desc Defines a shader used in a specific render pass.
	///
	/// @param {Real} _pass The render pass. Use values from {@link BBMOD_ERenderPass}.
	/// @param {Struct.BBMOD_Shader} _shader The shader used in the render pass.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	///
	/// @see BBMOD_Material.get_shader
	/// @see bbmod_render_pass_set
	static set_shader = function (_pass, _shader)
	{
		gml_pragma("forceinline");
		RenderPass |= (1 << _pass);
		__shaders[@ _pass] = _shader;
		HashDirty = true;
		return self;
	};

	/// @func has_shader(_pass)
	///
	/// @desc Checks whether the material has a shader for the render pass.
	///
	/// @param {Real} _pass The render pass. Use values from {@link BBMOD_ERenderPass}.
	///
	/// @return {Bool} Returns `true` if the material has a shader for the
	/// render pass.
	static has_shader = function (_pass)
	{
		gml_pragma("forceinline");
		return ((RenderPass & (1 << _pass)) != 0);
	};

	/// @func get_shader(_pass)
	///
	/// @desc Retrieves a shader used in a specific render pass.
	///
	/// @param {Real} _pass The render pass. Use values from
	/// {@link BBMOD_ERenderPass}.
	///
	/// @return {Struct.BBMOD_Shader} The shader or `undefined`.
	///
	/// @see BBMOD_Material.set_shader
	static get_shader = function (_pass)
	{
		gml_pragma("forceinline");
		return __shaders[_pass];
	};

	/// @func remove_shader(_pass)
	///
	/// @desc Removes a shader used in a specific render pass.
	///
	/// @param {Real} _pass The render pass.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static remove_shader = function (_pass)
	{
		gml_pragma("forceinline");
		RenderPass &= ~(1 << _pass);
		__shaders[@ _pass] = undefined;
		return self;
	};

	/// @func reset()
	///
	/// @desc Resets the current material to `undefined`.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	///
	/// @see BBMOD_Material.apply
	/// @see bbmod_material_reset
	static reset = function ()
	{
		gml_pragma("forceinline");
		bbmod_material_reset();
		return self;
	};

	/// @func get_hash()
	///
	/// @desc Computes a hash value that uniquely identifies this material's
	/// configuration based on all its properties and shaders.
	///
	/// @return {Real} A hash value representing the material's state.
	///
	/// @see bbmod_hash_combine
	/// @see bbmod_hash_array
	static get_hash = function ()
	{
		if (!HashDirty)
		{
			return __hash;
		}

		var _hash = 0;

		// Hash shaders for all render passes
		var i = 0;
		repeat(BBMOD_ERenderPass.SIZE)
		{
			var _shader = __shaders[i++];
			_hash = bbmod_hash_combine(_hash, _shader != undefined ? ptr(_shader) : 0);
		}

		// Hash GPU state properties
		_hash = bbmod_hash_combine(_hash, BlendMode);
		_hash = bbmod_hash_combine(_hash, Culling);
		_hash = bbmod_hash_combine(_hash, ZWrite);
		_hash = bbmod_hash_combine(_hash, ZTest);
		_hash = bbmod_hash_combine(_hash, ZFunc);
		_hash = bbmod_hash_combine(_hash, AlphaTest);
		_hash = bbmod_hash_combine(_hash, AlphaBlend);

		// Hash texture sampling properties
		_hash = bbmod_hash_combine(_hash, Mipmapping);
		_hash = bbmod_hash_combine(_hash, MipBias);
		_hash = bbmod_hash_combine(_hash, MipFilter);
		_hash = bbmod_hash_combine(_hash, MipMin);
		_hash = bbmod_hash_combine(_hash, MipMax);
		_hash = bbmod_hash_combine(_hash, Anisotropy);
		_hash = bbmod_hash_combine(_hash, Filtering);
		_hash = bbmod_hash_combine(_hash, Repeat);

		// Hash material textures
		_hash = bbmod_hash_combine(_hash, BaseOpacity ?? 0);
		_hash = bbmod_hash_combine(_hash, NormalSmoothness ?? 0);
		_hash = bbmod_hash_combine(_hash, SpecularColor ?? 0);
		_hash = bbmod_hash_combine(_hash, NormalRoughness ?? 0);
		_hash = bbmod_hash_combine(_hash, MetallicAO ?? 0);
		_hash = bbmod_hash_combine(_hash, Subsurface ?? 0);
		_hash = bbmod_hash_combine(_hash, Emissive ?? 0);
		_hash = bbmod_hash_combine(_hash, Lightmap ?? 0);

		// Hash color multipliers and offsets
		_hash = bbmod_hash_combine(_hash, BaseOpacityMultiplier.Red);
		_hash = bbmod_hash_combine(_hash, BaseOpacityMultiplier.Green);
		_hash = bbmod_hash_combine(_hash, BaseOpacityMultiplier.Blue);
		_hash = bbmod_hash_combine(_hash, BaseOpacityMultiplier.Alpha);

		// Hash texture transform
		_hash = bbmod_hash_combine(_hash, TextureOffset.X);
		_hash = bbmod_hash_combine(_hash, TextureOffset.Y);
		_hash = bbmod_hash_combine(_hash, TextureScale.X);
		_hash = bbmod_hash_combine(_hash, TextureScale.Y);

		// Hash other material properties
		_hash = bbmod_hash_combine(_hash, ShadowmapBias);
		_hash = bbmod_hash_combine(_hash, TwoSided);
		_hash = bbmod_hash_combine(_hash, SoftDistance);

		__hash = _hash;
		HashDirty = false;

		return _hash;
	};

	static destroy = function ()
	{
		Resource_destroy();
		if (__baseOpacitySprite != undefined)
		{
			sprite_delete(__baseOpacitySprite);
			__baseOpacitySprite = undefined;
		}
		if (__normalSmoothnessSprite != undefined)
		{
			sprite_delete(__normalSmoothnessSprite);
			__normalSmoothnessSprite = undefined;
		}
		if (__specularColorSprite != undefined)
		{
			sprite_delete(__specularColorSprite);
			__specularColorSprite = undefined;
		}
		if (__normalRoughnessSprite != undefined)
		{
			sprite_delete(__normalRoughnessSprite);
			__normalRoughnessSprite = undefined;
		}
		if (__metallicAOSprite != undefined)
		{
			sprite_delete(__metallicAOSprite);
			__metallicAOSprite = undefined;
		}
		if (__subsurfaceSprite != undefined)
		{
			sprite_delete(__subsurfaceSprite);
			__subsurfaceSprite = undefined;
		}
		if (__emissiveSprite != undefined)
		{
			sprite_delete(__emissiveSprite);
			__emissiveSprite = undefined;
		}
		return undefined;
	};

	if (_shader != undefined)
	{
		set_shader(BBMOD_ERenderPass.Forward, _shader);
	}
}

/// @func bbmod_material_reset()
///
/// @desc Resets the current material to `undefined`. Must be called after every
/// block of code that submits models or render queues!
///
/// @example
/// ```gml
/// // Submit static batch of trees
/// treeBatch.submit(matTree);
///
/// // Submit characters
/// var _world = matrix_get(matrix_world);
/// with(OCharacter)
/// {
///     matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, direction, 1, 1, 1));
///     animationPlayer.submit();
/// }
/// matrix_set(matrix_world, _world);
///
/// // Reset materials after submits!
/// bbmod_material_reset();
/// ```
///
/// @see BBMOD_Model.submit
/// @see BBMOD_AnimationPlayer.submit
/// @see BBMOD_DynamicBatch.submit
/// @see BBMOD_Terrain.submit
/// @see BBMOD_RenderQueue.submit
/// @see BBMOD_Material.reset
function bbmod_material_reset()
{
	gml_pragma("forceinline");
	if (global.__bbmodMaterialCurrent != undefined)
	{
		gpu_pop_state();
		global.__bbmodMaterialCurrent = undefined;
	}
	if (BBMOD_SHADER_CURRENT != undefined)
	{
		BBMOD_SHADER_CURRENT.reset();
	}
}
