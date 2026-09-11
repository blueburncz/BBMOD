/// @module PostProcessing

/// @func BBMOD_ColorGradingEffect([_lut])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Color grading (post-processing effect).
///
/// @param {Pointer.Texture} [_lut] The lookup table texture used for color
/// grading. Defaults to `BBMOD_SprColorGradingLUT` if `undefined`.
function BBMOD_ColorGradingEffect(_lut = undefined): BBMOD_PostProcessEffect() constructor
{
	static PostProcessEffect_destroy = destroy;
	static PostProcessEffect_to_buffer = to_buffer;
	static PostProcessEffect_from_buffer = from_buffer;

	/// @var {Pointer.Texture} The lookup table texture used for color grading.
	/// Default value is `BBMOD_SprColorGradingLUT`.
	LUT = _lut ?? sprite_get_texture(BBMOD_SprColorGradingLUT, 0);

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	LUTFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_ColorGradingEffect.LUT}, or `undefined`.
	/// Takes precedence over the texture when defined.
	LUTSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_ColorGradingEffect.LUTSprite} to use.
	LUTSubimage = 0;

	/// @var {Bool} Whether this effect owns
	/// {@link BBMOD_ColorGradingEffect.LUTSprite}.
	LUTOwned = false;

	static __uLUT = shader_get_sampler_index(BBMOD_ShColorGrading, "u_texLUT");

	static to_buffer = function (_buffer)
	{
		PostProcessEffect_to_buffer(_buffer);
		bbmod_texture_ref_to_buffer(_buffer, self, "LUT");
		return self;
	};

	static from_buffer = function (_buffer)
	{
		PostProcessEffect_from_buffer(_buffer);
		bbmod_texture_ref_from_buffer(_buffer, self, "LUT");
		return self;
	};

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShColorGrading);
		var _lut = bbmod_texture_ref_resolve(LUT, LUTSprite, LUTSubimage);
		texture_set_stage(__uLUT, _lut);
		gpu_push_state();
		gpu_set_tex_filter_ext(__uLUT, false);
		draw_surface(_surfaceSrc, 0, 0);
		gpu_pop_state();
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};

	static destroy = function ()
	{
		PostProcessEffect_destroy();
		bbmod_texture_ref_destroy(self, "LUT");
		return undefined;
	};
}
