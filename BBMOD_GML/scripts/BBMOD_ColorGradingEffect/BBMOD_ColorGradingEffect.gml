/// @module PostProcessing

/// @func BBMOD_ColorGradingEffect([_lut])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Color grading (post-processing effect).
///
/// @param {Pointer.Texture} [_lut] The lookup table texture used for color
/// grading. Defaults to `BBMOD_SprColorGradingLUT` if `undefined`.
function BBMOD_ColorGradingEffect(_lut=undefined)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Pointer.Texture} The lookup table texture used for color grading.
	/// Default value is `BBMOD_SprColorGradingLUT`.
	LUT = _lut ?? sprite_get_texture(BBMOD_SprColorGradingLUT, 0);

	static __uLUT = shader_get_sampler_index(BBMOD_ShColorGrading, "u_texLUT");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShColorGrading);
		texture_set_stage(__uLUT, LUT);
		gpu_push_state();
		gpu_set_tex_filter_ext(__uLUT, false);
		draw_surface(_surfaceSrc, 0, 0);
		gpu_pop_state();
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};
}
