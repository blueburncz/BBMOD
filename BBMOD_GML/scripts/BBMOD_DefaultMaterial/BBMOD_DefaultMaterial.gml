/// @func BBMOD_DefaultMaterial([_shader])
/// @extends BBMOD_BaseMaterial
/// @desc A material that can be used when rendering models.
/// @param {BBMOD_DefaultShader/undefined} [_shader] A shader that the material
/// uses in the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you
/// would like to use {@link BBMOD_BaseMaterial.set_shader} to specify shaders
/// used in specific render passes.
/// @see BBMOD_DefaultShader
function BBMOD_DefaultMaterial(_shader=undefined)
	: BBMOD_BaseMaterial(_shader) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_BaseMaterial = {
		copy: copy,
		destroy: destroy,
	};

	/// @var {ptr} A texture with tangent-space normals in the RGB channels and
	/// smoothness in the alpha channel.
	NormalSmoothness = pointer_null;

	NormalSmoothnessSprite = undefined;

	static _normalRoughnessDefault = undefined;
	if (_normalRoughnessDefault == undefined)
	{
		set_normal_smoothness(BBMOD_VEC3_UP, 0.5);
		_normalRoughnessDefault = NormalSmoothnessSprite;
		NormalSmoothnessSprite = undefined;
	}
	NormalSmoothness = sprite_get_texture(_normalRoughnessDefault, 0);

	/// @var {ptr} A texture specular color in the RGB channels.
	SpecularColor = pointer_null;

	SpecularColorSprite = undefined;

	static _specularColorDefault = undefined;
	if (_specularColorDefault == undefined)
	{
		set_specular_color(new BBMOD_Color(10.2, 10.2, 10.2));
		_specularColorDefault = SpecularColorSprite;
		SpecularColorSprite = undefined;
	}
	SpecularColor = sprite_get_texture(_specularColorDefault, 0);

	/// @func set_normal_smoothness(_normal, _smoothness)
	/// @desc Changes the normal vector and smoothness to a uniform value for the
	/// entire material.
	/// @param {BBMOD_Vec3} _normal The new normal vector. If you are not sure
	/// what this value should be, use {@link BBMOD_VEC3_UP}.
	/// @param {real} _smoothness The new smoothness. Use values in range 0..1.
	/// @return {BBMOD_DefaultMaterial} Returns `self`.
	static set_normal_smoothness = function (_normal, _smoothness) {
		if (NormalSmoothnessSprite != undefined)
		{
			sprite_delete(NormalSmoothnessSprite);
		}
		_normal = _normal.Normalize();
		NormalSmoothnessSprite = _make_sprite(
			(_normal.X * 0.5 + 0.5) * 255.0,
			(_normal.Y * 0.5 + 0.5) * 255.0,
			(_normal.Z * 0.5 + 0.5) * 255.0,
			_smoothness,
		);
		NormalSmoothness = sprite_get_texture(NormalSmoothnessSprite, 0);
		return self;
	};

	/// @func set_specular_color(_color)
	/// @desc Changes the specular color to a uniform value for the entire material.
	/// @param {BBMOD_Color} _color The new specular color.
	/// @return {BBMOD_DefaultMaterial} Returns `self`.
	static set_specular_color = function (_color) {
		if (SpecularColorSprite != undefined)
		{
			sprite_delete(SpecularColorSprite);
		}
		SpecularColorSprite = _make_sprite(
			_color.Red,
			_color.Green,
			_color.Blue,
			1.0,
		);
		SpecularColor = sprite_get_texture(SpecularColorSprite, 0);
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
	};
}