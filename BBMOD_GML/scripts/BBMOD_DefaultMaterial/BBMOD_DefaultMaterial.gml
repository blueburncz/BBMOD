/// @module Core

/// @func BBMOD_DefaultMaterial([_shader])
///
/// @extends BBMOD_BaseMaterial
///
/// @desc A material that can be used when rendering models.
///
/// @param {Struct.BBMOD_DefaultShader} [_shader] A shader that the material
/// uses in the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you
/// would like to use {@link BBMOD_Material.set_shader} to specify shaders used
/// in specific render passes.
///
/// @see BBMOD_DefaultShader
function BBMOD_DefaultMaterial(_shader = undefined): BBMOD_BaseMaterial(_shader) constructor
{
	static BaseMaterial_copy = copy;
	static BaseMaterial_get_hash = get_hash;
	static BaseMaterial_to_json = to_json;
	static BaseMaterial_from_json = from_json;
	static BaseMaterial_destroy = destroy;

	/// @var {Pointer.Texture} A texture with tangent-space normals in the RGB
	/// channels and smoothness in the alpha channel or `undefined`.
	NormalSmoothness = sprite_get_texture(BBMOD_SprDefaultNormalW, 0);

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	NormalSmoothnessFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_DefaultMaterial.NormalSmoothness}, or
	/// `undefined`. Takes precedence over the texture when defined.
	NormalSmoothnessSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_DefaultMaterial.NormalSmoothnessSprite} to use.
	NormalSmoothnessSubimage = 0;

	/// @var {Bool} Whether this material owns
	/// {@link BBMOD_DefaultMaterial.NormalSmoothnessSprite}.
	NormalSmoothnessOwned = false;

	/// @var {Pointer.Texture} A texture with specular color in the RGB channels
	/// or `undefined`.
	SpecularColor = sprite_get_texture(BBMOD_SprDefaultSpecularColor, 0);

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	SpecularColorFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_DefaultMaterial.SpecularColor}, or
	/// `undefined`. Takes precedence over the texture when defined.
	SpecularColorSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_DefaultMaterial.SpecularColorSprite} to use.
	SpecularColorSubimage = 0;

	/// @var {Bool} Whether this material owns
	/// {@link BBMOD_DefaultMaterial.SpecularColorSprite}.
	SpecularColorOwned = false;

	/// @var {Pointer.Texture} A texture with tangent-space normals in the RGB
	/// channels and roughness in the alpha channel or `undefined`.
	NormalRoughness = undefined;

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	NormalRoughnessFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_DefaultMaterial.NormalRoughness}, or
	/// `undefined`. Takes precedence over the texture when defined.
	NormalRoughnessSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_DefaultMaterial.NormalRoughnessSprite} to use.
	NormalRoughnessSubimage = 0;

	/// @var {Bool} Whether this material owns
	/// {@link BBMOD_DefaultMaterial.NormalRoughnessSprite}.
	NormalRoughnessOwned = false;

	/// @var {Pointer.Texture} A texture with metallic in the red channel and
	/// ambient occlusion in the green channel or `undefined`.
	MetallicAO = undefined;

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	MetallicAOFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_DefaultMaterial.MetallicAO}, or
	/// `undefined`. Takes precedence over the texture when defined.
	MetallicAOSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_DefaultMaterial.MetallicAOSprite} to use.
	MetallicAOSubimage = 0;

	/// @var {Bool} Whether this material owns
	/// {@link BBMOD_DefaultMaterial.MetallicAOSprite}.
	MetallicAOOwned = false;

	/// @var {Pointer.Texture} A texture with subsurface color in the RGB
	/// channels and subsurface effect intensity in the alpha channel.
	Subsurface = sprite_get_texture(BBMOD_SprBlack, 0);

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	SubsurfaceFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_DefaultMaterial.Subsurface}, or
	/// `undefined`. Takes precedence over the texture when defined.
	SubsurfaceSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_DefaultMaterial.SubsurfaceSprite} to use.
	SubsurfaceSubimage = 0;

	/// @var {Bool} Whether this material owns
	/// {@link BBMOD_DefaultMaterial.SubsurfaceSprite}.
	SubsurfaceOwned = false;

	/// @var {Pointer.Texture} RGBM encoded emissive texture.
	Emissive = sprite_get_texture(BBMOD_SprBlack, 0);

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	EmissiveFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_DefaultMaterial.Emissive}, or
	/// `undefined`. Takes precedence over the texture when defined.
	EmissiveSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_DefaultMaterial.EmissiveSprite} to use.
	EmissiveSubimage = 0;

	/// @var {Bool} Whether this material owns
	/// {@link BBMOD_DefaultMaterial.EmissiveSprite}.
	EmissiveOwned = false;

	static to_json = function (_json)
	{
		BaseMaterial_to_json(_json);
		bbmod_texture_ref_to_json(_json, self, "NormalSmoothness");
		bbmod_texture_ref_to_json(_json, self, "SpecularColor");
		bbmod_texture_ref_to_json(_json, self, "NormalRoughness");
		bbmod_texture_ref_to_json(_json, self, "MetallicAO");
		bbmod_texture_ref_to_json(_json, self, "Subsurface");
		bbmod_texture_ref_to_json(_json, self, "Emissive");
		return self;
	};

	static from_json = function (_json)
	{
		bbmod_texture_ref_from_json(_json, self, "NormalSmoothness");
		bbmod_texture_ref_from_json(_json, self, "SpecularColor");
		bbmod_texture_ref_from_json(_json, self, "NormalRoughness");
		bbmod_texture_ref_from_json(_json, self, "MetallicAO");
		bbmod_texture_ref_from_json(_json, self, "Subsurface");
		bbmod_texture_ref_from_json(_json, self, "Emissive");
		BaseMaterial_from_json(_json);

		HashDirty = true;

		return self;
	};

	/// @func set_normal_smoothness(_normal, _smoothness)
	///
	/// @desc Changes the normal vector and smoothness to a uniform value for
	/// the entire material.
	///
	/// @param {Struct.BBMOD_Vec3} _normal The new normal vector. If you are not
	/// sure what this value should be, use {@link BBMOD_VEC3_UP}.
	/// @param {Real} _smoothness The new smoothness. Use values in range 0..1.
	///
	/// @return {Struct.BBMOD_DefaultMaterial} Returns `self`.
	static set_normal_smoothness = function (_normal, _smoothness)
	{
		NormalRoughness = undefined;
		bbmod_texture_ref_destroy(self, "NormalRoughness");
		bbmod_texture_ref_destroy(self, "NormalSmoothness");
		_normal = _normal.Normalize();
		NormalSmoothnessSprite = _make_sprite(
			(_normal.X * 0.5 + 0.5) * 255.0,
			(_normal.Y * 0.5 + 0.5) * 255.0,
			(_normal.Z * 0.5 + 0.5) * 255.0,
			_smoothness
		);
		NormalSmoothnessSubimage = 0;
		NormalSmoothnessOwned = true;
		NormalSmoothness = sprite_get_texture(NormalSmoothnessSprite, 0);
		HashDirty = true;
		return self;
	};

	/// @func set_specular_color(_color)
	///
	/// @desc Changes the specular color to a uniform value for the entire
	/// material.
	///
	/// @param {Struct.BBMOD_Color} _color The new specular color.
	///
	/// @return {Struct.BBMOD_DefaultMaterial} Returns `self`.
	static set_specular_color = function (_color)
	{
		MetallicAO = undefined;
		bbmod_texture_ref_destroy(self, "MetallicAO");
		bbmod_texture_ref_destroy(self, "SpecularColor");
		SpecularColorSprite = _make_sprite(
			_color.Red,
			_color.Green,
			_color.Blue,
			1.0
		);
		SpecularColorSubimage = 0;
		SpecularColorOwned = true;
		SpecularColor = sprite_get_texture(SpecularColorSprite, 0);
		HashDirty = true;
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
	/// @return {Struct.BBMOD_DefaultMaterial} Returns `self`.
	static set_normal_roughness = function (_normal, _roughness)
	{
		NormalSmoothness = undefined;
		bbmod_texture_ref_destroy(self, "NormalSmoothness");
		bbmod_texture_ref_destroy(self, "NormalRoughness");
		_normal = _normal.Normalize();
		NormalRoughnessSprite = _make_sprite(
			(_normal.X * 0.5 + 0.5) * 255.0,
			(_normal.Y * 0.5 + 0.5) * 255.0,
			(_normal.Z * 0.5 + 0.5) * 255.0,
			_roughness
		);
		NormalRoughnessSubimage = 0;
		NormalRoughnessOwned = true;
		NormalRoughness = sprite_get_texture(NormalRoughnessSprite, 0);
		HashDirty = true;
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
	/// @return {Struct.BBMOD_DefaultMaterial} Returns `self`.
	static set_metallic_ao = function (_metallic, _ao)
	{
		SpecularColor = undefined;
		bbmod_texture_ref_destroy(self, "SpecularColor");
		bbmod_texture_ref_destroy(self, "MetallicAO");
		MetallicAOSprite = _make_sprite(
			_metallic * 255.0,
			_ao * 255.0,
			0.0,
			0.0
		);
		MetallicAOSubimage = 0;
		MetallicAOOwned = true;
		MetallicAO = sprite_get_texture(MetallicAOSprite, 0);
		HashDirty = true;
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
	/// @return {Struct.BBMOD_DefaultMaterial} Returns `self`.
	static set_subsurface = function (_color, _intensity)
	{
		bbmod_texture_ref_destroy(self, "Subsurface");
		SubsurfaceSprite = _make_sprite(
			color_get_red(_color),
			color_get_green(_color),
			color_get_blue(_color),
			_intensity
		);
		SubsurfaceSubimage = 0;
		SubsurfaceOwned = true;
		Subsurface = sprite_get_texture(SubsurfaceSprite, 0);
		HashDirty = true;
		return self;
	};

	/// @func set_emissive(_color)
	///
	/// @desc Changes the emissive color to a uniform value for the entire
	/// material.
	///
	/// @param {Struct.BBMOD_Color} _color The new emissive color.
	///
	/// @return {Struct.BBMOD_DefaultMaterial} Returns `self`.
	static set_emissive = function ()
	{
		var _color = (argument_count == 3)
			? new BBMOD_Color(argument[0], argument[1], argument[2])
			: argument[0];
		var _rgbm = _color.ToRGBM();
		bbmod_texture_ref_destroy(self, "Emissive");
		EmissiveSprite = _make_sprite(
			_rgbm[0] * 255.0,
			_rgbm[1] * 255.0,
			_rgbm[2] * 255.0,
			_rgbm[3]
		);
		EmissiveSubimage = 0;
		EmissiveOwned = true;
		Emissive = sprite_get_texture(EmissiveSprite, 0);
		HashDirty = true;
		return self;
	};

	static copy = function (_dest)
	{
		BaseMaterial_copy(_dest);
		bbmod_texture_ref_copy(self, _dest, "NormalSmoothness");
		bbmod_texture_ref_copy(self, _dest, "SpecularColor");
		bbmod_texture_ref_copy(self, _dest, "NormalRoughness");
		bbmod_texture_ref_copy(self, _dest, "MetallicAO");
		bbmod_texture_ref_copy(self, _dest, "Subsurface");
		bbmod_texture_ref_copy(self, _dest, "Emissive");

		_dest.HashDirty = true;

		return self;
	};

	static clone = function ()
	{
		var _clone = new BBMOD_DefaultMaterial();
		copy(_clone);
		return _clone;
	};

	static get_hash = function ()
	{
		if (!HashDirty)
		{
			return __hash;
		}

		var _hash = BaseMaterial_get_hash();

		_hash = bbmod_hash_combine(_hash, NormalSmoothness ?? 0);
		_hash = bbmod_hash_combine(_hash, SpecularColor ?? 0);
		_hash = bbmod_hash_combine(_hash, NormalRoughness ?? 0);
		_hash = bbmod_hash_combine(_hash, MetallicAO ?? 0);
		_hash = bbmod_hash_combine(_hash, Subsurface ?? 0);
		_hash = bbmod_hash_combine(_hash, Emissive ?? 0);

		__hash = _hash;
		HashDirty = false;

		return __hash;
	};

	static destroy = function ()
	{
		BaseMaterial_destroy();
		bbmod_texture_ref_destroy(self, "NormalSmoothness");
		bbmod_texture_ref_destroy(self, "SpecularColor");
		bbmod_texture_ref_destroy(self, "NormalRoughness");
		bbmod_texture_ref_destroy(self, "MetallicAO");
		bbmod_texture_ref_destroy(self, "Subsurface");
		bbmod_texture_ref_destroy(self, "Emissive");
		return undefined;
	};
}
