/// @macro {BBMOD_PBRShader} PBR shader for static models.
/// @see BBMOD_PBRShader
#macro BBMOD_SHADER_PBR __bbmod_shader_pbr()

/// @macro {BBMOD_PBRShader} PBR shader for animated models with bones.
/// @see BBMOD_PBRShader
#macro BBMOD_SHADER_PBR_ANIMATED __bbmod_shader_pbr_animated()

/// @macro {BBMOD_PBRShader} PBR shader for dynamically batched models.
/// @see BBMOD_PBRShader
/// @see BBMOD_DynamicBatch
#macro BBMOD_SHADER_PBR_BATCHED __bbmod_shader_pbr_batched()

/// @macro {BBMOD_PBRMaterial} PBR material for static models.
/// @see BBMOD_PBRMaterial
#macro BBMOD_MATERIAL_PBR __bbmod_material_pbr()

/// @macro {BBMOD_PBRMaterial} PBR material for animated models with bones.
/// @see BBMOD_PBRMaterial
#macro BBMOD_MATERIAL_PBR_ANIMATED __bbmod_material_pbr_animated()

/// @macro {BBMOD_PBRMaterial} PBR material for dynamically batched models.
/// @see BBMOD_PBRMaterial
/// @see BBMOD_DynamicBatch
#macro BBMOD_MATERIAL_PBR_BATCHED __bbmod_material_pbr_batched()

/// @func BBMOD_PBRMaterial(_shader)
/// @extends BBMOD_Material
/// @desc A PBR material using the metallic-rougness workflow.
/// @param {BBMOD_Shader} _shader A shader that the material uses.
function BBMOD_PBRMaterial(_shader)
	: BBMOD_Material(_shader) constructor
{
	static Super = {
		copy: copy,
		destroy: destroy,
	};

	/// @var {ptr} A texture with tangent-space normals in the RGB channels and
	/// roughness in the alpha channel.
	NormalRoughness = pointer_null;

	NormalRoughnessSprite = undefined;

	static _normalRoughnessDefault = undefined;
	if (_normalRoughnessDefault == undefined)
	{
		set_normal_roughness(BBMOD_VEC3_UP, 0.5);
		_normalRoughnessDefault = NormalRoughnessSprite;
		NormalRoughnessSprite = undefined;
	}

	NormalRoughness = sprite_get_texture(_normalRoughnessDefault, 0);

	/// @var {ptr} A texture with metallic in the red channel and ambient occlusion
	/// in the green channel.
	MetallicAO = pointer_null;

	MetallicAOSprite = undefined;

	static _metallicAoDefault = undefined;
	if (_metallicAoDefault == undefined)
	{
		set_metallic_ao(0.0, 1.0);
		_metallicAoDefault = MetallicAOSprite;
		MetallicAOSprite = undefined;
	}

	MetallicAO = sprite_get_texture(_metallicAoDefault, 0);

	/// @var {ptr} A texture with subsurface color in the RGB channels and
	/// subsurface effect intensity in the alpha channel.
	Subsurface = pointer_null;

	SubsurfaceSprite = undefined;

	static _subsurfaceDefault = undefined;
	if (_subsurfaceDefault == undefined)
	{
		set_subsurface(c_black, 0.0);
		_subsurfaceDefault = SubsurfaceSprite;
		SubsurfaceSprite = undefined;
	}

	Subsurface = sprite_get_texture(_subsurfaceDefault, 0);

	/// @var {ptr} RGBM encoded emissive texture.
	Emissive = pointer_null;

	EmissiveSprite = undefined;

	static _emissiveDefault = undefined;
	if (_emissiveDefault == undefined)
	{
		set_emissive(0, 0, 0);
		_emissiveDefault = EmissiveSprite;
		EmissiveSprite = undefined;
	}

	Emissive = sprite_get_texture(_emissiveDefault, 0);

	/// @func set_normal_roughness(_normal, _roughness)
	/// @desc Changes the normal vector and roughness to a uniform value for the
	/// entire material.
	/// @param {BBMOD_Vec3} _normal The new normal vector. If you are not sure
	/// what this value should be, use {@link BBMOD_VEC3_UP}.
	/// @param {real} _roughness The new roughness. Use values in range 0..1.
	/// @return {BBMOD_PBRMaterial} Returns `self`.
	static set_normal_roughness = function (_normal, _roughness) {
		if (NormalRoughnessSprite != undefined)
		{
			sprite_delete(NormalRoughnessSprite);
		}
		_normal = _normal.Normalize();
		NormalRoughnessSprite = _make_sprite(
			(_normal.X * 0.5 + 0.5) * 255.0,
			(_normal.Y * 0.5 + 0.5) * 255.0,
			(_normal.Z * 0.5 + 0.5) * 255.0,
			_roughness,
		);
		NormalRoughness = sprite_get_texture(NormalRoughnessSprite, 0);
		return self;
	};

	/// @func set_metallic_ao(_metallic, _ao)
	/// @desc Changes the metalness and ambient occlusion to a uniform value for
	/// the entire material.
	/// @param {real} _metallic The new metalness. You can use any value in range
	/// 0..1, but in general this is usually either 0 for dielectric materials
	/// and 1 for metals.
	/// @param {real} _ao The new ambient occlusion value. Use values in range 0..1,
	/// where 0 means full occlusion and 1 means no occlusion.
	/// @return {BBMOD_PBRMaterial} Returns `self`.
	static set_metallic_ao = function (_metallic, _ao) {
		if (MetallicAOSprite != undefined)
		{
			sprite_delete(MetallicAOSprite);
		}
		MetallicAOSprite = _make_sprite(
			_metallic * 255.0,
			_ao * 255.0,
			0.0,
			0.0,
		);
		MetallicAO = sprite_get_texture(MetallicAOSprite, 0);
		return self;
	};

	/// @func set_subsurface(_color, _intensity)
	/// @desc Changes the subsurface color to a uniform value for the entire
	/// material.
	/// @param {uint} _color The new subsurface color.
	/// @param {real} _intensity The subsurface color intensity. Use values in range 0..1.
	/// The higher the value, the more visible the effect is.
	/// @return {BBMOD_PBRMaterial} Returns `self`.
	static set_subsurface = function (_color, _intensity) {
		if (SubsurfaceSprite != undefined)
		{
			sprite_delete(SubsurfaceSprite);
		}
		SubsurfaceSprite = _make_sprite(
			color_get_red(_color),
			color_get_green(_color),
			color_get_blue(_color),
			_intensity,
		);
		Subsurface = sprite_get_texture(SubsurfaceSprite, 0);
		return self;
	};

	/// @func set_emissive(_red, _green, _blue)
	/// @desc Changes the emissive color to a uniform value for the entire material.
	/// @param {uint} _red The new value of the red channel. Accepts values in
	/// range 0..1530.
	/// @param {uint} _green The new value of the green channel. Accepts values in
	/// range 0..1530.
	/// @param {uint} _blue The new value of the blue channel. Accepts values in
	/// range 0..1530.
	/// @return {BBMOD_PBRMaterial} Returns `self`.
	static set_emissive = function (_red, _green, _blue) {
		var _range = 6.0;
		var _max = 255.0 * _range;

		_red = min(_red / _max, 1.0);
		_green = min(_green / _max, 1.0);
		_blue = min(_blue / _max, 1.0);

		var _a = clamp(max(_red, _green, _blue, 0.000001), 0.0, 1.0);
		_a = ceil(_a * 255.0) / 255.0;

		_red /= _a;
		_green /= _a;
		_blue /= _a;

		if (EmissiveSprite != undefined)
		{
			sprite_delete(EmissiveSprite);
		}
		EmissiveSprite = _make_sprite(
			_red * 255.0,
			_green * 255.0,
			_blue * 255.0,
			_a,
		);
		Emissive = sprite_get_texture(EmissiveSprite, 0);
		return self;
	};

	static copy = function (_dest) {
		method(self, Super.copy)(_dest);

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
		var _clone = new BBMOD_PBRMaterial(Shader);
		copy(_clone);
		return _clone;
	};

	static destroy = function () {
		method(self, Super.destroy)();
		if (NormalRoughnessSprite != undefined)
		{
			sprite_delete(NormalRoughnessSprite);
		}
		if (MetallicAO != undefined)
		{
			sprite_delete(MetallicAO);
		}
		if (SubsurfaceSprite != undefined)
		{
			sprite_delete(SubsurfaceSprite);
		}
		if (EmissiveSprite != undefined)
		{
			sprite_delete(EmissiveSprite);
		}
	};
}