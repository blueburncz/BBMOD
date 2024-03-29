/// @module PostProcessing

/// @func BBMOD_GammaCorrectEffect([_gamma])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Applies gamma correction (post-processing effect).
///
/// @param {Real} [_gamma] Gamma value. Defaults to 2.2.
function BBMOD_GammaCorrectEffect(_gamma=2.2)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Real} Gamma value. Default value is 2.2.
	Gamma = _gamma;

	static __uGamma = shader_get_uniform(BBMOD_ShGammaCorrect, "u_fGamma");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShGammaCorrect);
		shader_set_uniform_f(__uGamma, Gamma);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};
}
