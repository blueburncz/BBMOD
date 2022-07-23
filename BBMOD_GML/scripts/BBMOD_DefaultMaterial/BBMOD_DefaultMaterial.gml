/// @func BBMOD_DefaultMaterial([_shader])
///
/// @extends BBMOD_BaseMaterial
///
/// @desc A material that can be used when rendering models.
///
/// @param {Struct.BBMOD_DefaultShader} [_shader] A shader that the material
/// uses in the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you
/// would like to use {@link BBMOD_Material.set_shader} to specify shaders
/// used in specific render passes.
///
/// @see BBMOD_DefaultShader
function BBMOD_DefaultMaterial(_shader=undefined)
	: BBMOD_BaseMaterial(_shader) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_BaseMaterial = {
		copy: copy,
		destroy: destroy,
	};

	/// @var {Pointer.Texture} A texture with tangent-space normals in the RGB
	/// channels and smoothness in the alpha channel or `undefined`.
	NormalSmoothness = sprite_get_texture(BBMOD_SprDefaultNormalW, 0);

	NormalSmoothnessSprite = undefined;

	/// @var {Pointer.Texture} A texture specular color in the RGB channels
	/// or `undefined`.
	SpecularColor = sprite_get_texture(BBMOD_SprDefaultSpecularColor, 0);

	SpecularColorSprite = undefined;

	/// @var {Pointer.Texture} A texture with tangent-space normals in the RGB
	/// channels and roughness in the alpha channel or `undefined`.
	NormalRoughness = undefined;

	NormalRoughnessSprite = undefined;

	/// @var {Pointer.Texture} A texture with metallic in the red channel and
	/// ambient occlusion in the green channel or `undefined`.
	MetallicAO = undefined;

	MetallicAOSprite = undefined;

	/// @var {Pointer.Texture} A texture with subsurface color in the RGB
	/// channels and subsurface effect intensity in the alpha channel.
	Subsurface = sprite_get_texture(BBMOD_SprBlack, 0);

	SubsurfaceSprite = undefined;

	/// @var {Pointer.Texture} RGBM encoded emissive texture.
	Emissive = sprite_get_texture(BBMOD_SprBlack, 0);

	EmissiveSprite = undefined;

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
	static set_normal_smoothness = function (_normal, _smoothness) {
		NormalRoughness = undefined;
		if (NormalRoughnessSprite != undefined)
		{
			sprite_delete(NormalRoughnessSprite);
			NormalRoughnessSprite = undefined;
		}

		if (NormalSmoothnessSprite != undefined)
		{
			sprite_delete(NormalSmoothnessSprite);
		}
		_normal = _normal.Normalize();
		NormalSmoothnessSprite = _make_sprite(
			(_normal.X * 0.5 + 0.5) * 255.0,
			(_normal.Y * 0.5 + 0.5) * 255.0,
			(_normal.Z * 0.5 + 0.5) * 255.0,
			_smoothness
		);
		NormalSmoothness = sprite_get_texture(NormalSmoothnessSprite, 0);
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
	static set_specular_color = function (_color) {
		MetallicAO = undefined;
		if (MetallicAOSprite != undefined)
		{
			sprite_delete(MetallicAOSprite);
			MetallicAOSprite = undefined;
		}

		if (SpecularColorSprite != undefined)
		{
			sprite_delete(SpecularColorSprite);
		}
		SpecularColorSprite = _make_sprite(
			_color.Red,
			_color.Green,
			_color.Blue,
			1.0
		);
		SpecularColor = sprite_get_texture(SpecularColorSprite, 0);
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
	/// @return {Struct.BBMOD_PBRMaterial} Returns `self`.
	static set_normal_roughness = function (_normal, _roughness) {
		NormalSmoothness = undefined;
		if (NormalSmoothnessSprite != undefined)
		{
			sprite_delete(NormalSmoothnessSprite);
			NormalSmoothnessSprite = undefined;
		}

		if (NormalRoughnessSprite != undefined)
		{
			sprite_delete(NormalRoughnessSprite);
		}
		_normal = _normal.Normalize();
		NormalRoughnessSprite = _make_sprite(
			(_normal.X * 0.5 + 0.5) * 255.0,
			(_normal.Y * 0.5 + 0.5) * 255.0,
			(_normal.Z * 0.5 + 0.5) * 255.0,
			_roughness
		);
		NormalRoughness = sprite_get_texture(NormalRoughnessSprite, 0);
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
	/// @return {Struct.BBMOD_PBRMaterial} Returns `self`.
	static set_metallic_ao = function (_metallic, _ao) {
		SpecularColor = undefined;
		if (SpecularColorSprite != undefined)
		{
			sprite_delete(SpecularColorSprite);
			SpecularColorSprite = undefined;
		}

		if (MetallicAOSprite != undefined)
		{
			sprite_delete(MetallicAOSprite);
		}
		MetallicAOSprite = _make_sprite(
			_metallic * 255.0,
			_ao * 255.0,
			0.0,
			0.0
		);
		MetallicAO = sprite_get_texture(MetallicAOSprite, 0);
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
	/// @return {Struct.BBMOD_PBRMaterial} Returns `self`.
	static set_subsurface = function (_color, _intensity) {
		if (SubsurfaceSprite != undefined)
		{
			sprite_delete(SubsurfaceSprite);
		}
		SubsurfaceSprite = _make_sprite(
			color_get_red(_color),
			color_get_green(_color),
			color_get_blue(_color),
			_intensity
		);
		Subsurface = sprite_get_texture(SubsurfaceSprite, 0);
		return self;
	};

	/// @func set_emissive(_color)
	///
	/// @desc Changes the emissive color to a uniform value for the entire
	/// material.
	///
	/// @param {Struct.BBMOD_Color} _color The new emissive color.
	///
	/// @return {Struct.BBMOD_PBRMaterial} Returns `self`.
	static set_emissive = function () {
		var _color = (argument_count == 3)
			? new BBMOD_Color(argument[0], argument[1], argument[2])
			: argument[0];
		var _rgbm = _color.ToRGBM();
		if (EmissiveSprite != undefined)
		{
			sprite_delete(EmissiveSprite);
		}
		EmissiveSprite = _make_sprite(
			_rgbm[0] * 255.0,
			_rgbm[1] * 255.0,
			_rgbm[2] * 255.0,
			_rgbm[3]
		);
		Emissive = sprite_get_texture(EmissiveSprite, 0);
		return self;
	};

	static copy = function (_dest) {
		method(self, Super_BaseMaterial.copy)(_dest);

		// NormalSmoothness
		if (_dest.NormalSmoothnessSprite != undefined)
		{
			sprite_delete(_dest.NormalSmoothnessSprite);
			_dest.NormalSmoothnessSprite = undefined;
		}

		if (NormalSmoothnessSprite != undefined)
		{
			_dest.NormalSmoothnessSprite = sprite_duplicate(NormalSmoothnessSprite);
			_dest.NormalSmoothness = sprite_get_texture(_dest.NormalSmoothnessSprite, 0);
		}
		else
		{
			_dest.NormalSmoothness = NormalSmoothness;
		}

		// SpecularColor
		if (_dest.SpecularColorSprite != undefined)
		{
			sprite_delete(_dest.SpecularColorSprite);
			_dest.SpecularColorSprite = undefined;
		}

		if (SpecularColorSprite != undefined)
		{
			_dest.SpecularColorSprite = sprite_duplicate(SpecularColorSprite);
			_dest.SpecularColor = sprite_get_texture(_dest.SpecularColorSprite, 0);
		}
		else
		{
			_dest.SpecularColor = SpecularColor;
		}

		// NormalRoughness
		if (_dest.NormalRoughnessSprite != undefined)
		{
			sprite_delete(_dest.NormalRoughnessSprite);
			_dest.NormalRoughnessSprite = undefined;
		}

		if (NormalRoughnessSprite != undefined)
		{
			_dest.NormalRoughnessSprite = sprite_duplicate(NormalRoughnessSprite);
			_dest.NormalRoughness = sprite_get_texture(_dest.NormalRoughnessSprite, 0);
		}
		else
		{
			_dest.NormalRoughness = NormalRoughness;
		}

		// MetallicAO
		if (_dest.MetallicAOSprite != undefined)
		{
			sprite_delete(_dest.MetallicAOSprite);
			_dest.MetallicAOSprite = undefined;
		}

		if (MetallicAOSprite != undefined)
		{
			_dest.MetallicAOSprite = sprite_duplicate(MetallicAOSprite);
			_dest.MetallicAO = sprite_get_texture(_dest.MetallicAOSprite, 0);
		}
		else
		{
			_dest.MetallicAO = MetallicAO;
		}

		// Subsurface
		if (_dest.SubsurfaceSprite != undefined)
		{
			sprite_delete(_dest.SubsurfaceSprite);
			_dest.SubsurfaceSprite = undefined;
		}

		if (SubsurfaceSprite != undefined)
		{
			_dest.SubsurfaceSprite = sprite_duplicate(SubsurfaceSprite);
			_dest.Subsurface = sprite_get_texture(_dest.SubsurfaceSprite, 0);
		}
		else
		{
			_dest.Subsurface = Subsurface;
		}

		// Emissive
		if (_dest.EmissiveSprite != undefined)
		{
			sprite_delete(_dest.EmissiveSprite);
			_dest.EmissiveSprite = undefined;
		}

		if (EmissiveSprite != undefined)
		{
			_dest.EmissiveSprite = sprite_duplicate(EmissiveSprite);
			_dest.Emissive = sprite_get_texture(_dest.EmissiveSprite, 0);
		}
		else
		{
			_dest.Emissive = Emissive;
		}

		return self;
	};

	static clone = function () {
		var _clone = new BBMOD_DefaultMaterial();
		copy(_clone);
		return _clone;
	};

	static destroy = function () {
		method(self, Super_BaseMaterial.destroy)();
		if (NormalSmoothnessSprite != undefined)
		{
			sprite_delete(NormalSmoothnessSprite);
		}
		if (SpecularColorSprite != undefined)
		{
			sprite_delete(SpecularColorSprite);
		}
		if (NormalRoughnessSprite != undefined)
		{
			sprite_delete(NormalRoughnessSprite);
		}
		if (MetallicAOSprite != undefined)
		{
			sprite_delete(MetallicAOSprite);
		}
		if (SubsurfaceSprite != undefined)
		{
			sprite_delete(SubsurfaceSprite);
		}
		if (EmissiveSprite != undefined)
		{
			sprite_delete(EmissiveSprite);
		}
		return undefined;
	};
}
