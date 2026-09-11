/// @module PostProcessing

/// @func BBMOD_NormalDistortionEffect([_texture[, _strength]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Distort screen using a normal map texture (post-processing effect).
///
/// @param {Pointer.Texture} [_texture] A normal map texture. Defaults to
/// `(-1/*pointer_null*/)`.
/// @param {Real} [_strength] The strength of the effect. Both positive and
/// negative values can be used. Use 0 to disable the effect. Default value is
/// 1.
/* beautify ignore:start */
function BBMOD_NormalDistortionEffect(_texture = (-1 /*pointer_null*/ ), _strength = 1.0): BBMOD_PostProcessEffect() constructor
/* beautify ignore:end */
{
	static PostProcessEffect_destroy = destroy;

	/// @var {Pointer.Texture} A normal map texture. Default value is
	/// `(-1/*pointer_null*/)` (and the effect is not applied).
	Texture = _texture;

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	TextureFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_NormalDistortionEffect.Texture}, or `undefined`.
	/// Takes precedence over the texture when defined.
	TextureSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_NormalDistortionEffect.TextureSprite} to use.
	TextureSubimage = 0;

	/// @var {Bool} Whether this effect owns
	/// {@link BBMOD_NormalDistortionEffect.TextureSprite}.
	TextureOwned = false;

	/// @var {Real} The strength of the effect. Both positive and negative values
	/// can be used. Use 0 to disable the effect. Default value is 1.
	Strength = _strength;

	static __uNormal = shader_get_sampler_index(BBMOD_ShNormalDistortion, "u_texNormal");
	static __uNormalUVs = shader_get_uniform(BBMOD_ShNormalDistortion, "u_vNormalUVs");
	static __uStrength = shader_get_uniform(BBMOD_ShNormalDistortion, "u_fStrength");
	static __uTexel = shader_get_uniform(BBMOD_ShNormalDistortion, "u_vTexel");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		var _texture = bbmod_texture_ref_resolve(
			Texture, TextureSprite, TextureSubimage);
		if (_texture == (-1 /*pointer_null*/ )
			|| Strength == 0.0)
		{
			return _surfaceSrc;
		}
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShNormalDistortion);
		texture_set_stage(__uNormal, _texture);
		var _uvs = texture_get_uvs(_texture);
		shader_set_uniform_f(__uNormalUVs, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
		shader_set_uniform_f(__uStrength, Strength);
		shader_set_uniform_f(__uTexel, 1.0 / surface_get_width(_surfaceDest), 1.0 / surface_get_height(
			_surfaceDest));
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};

	static destroy = function ()
	{
		PostProcessEffect_destroy();
		bbmod_texture_ref_destroy(self, "Texture");
		return undefined;
	};
}
