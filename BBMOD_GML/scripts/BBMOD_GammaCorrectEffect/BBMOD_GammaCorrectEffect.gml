/// @module PostProcessing

/// @func BBMOD_GammaCorrectEffect([_gamma])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Applies gamma correction (post-processing effect).
///
/// @param {Real} [_gamma] Gamma value. Defaults to 2.2.
function BBMOD_GammaCorrectEffect(_gamma = 2.2): BBMOD_PostProcessEffect() constructor
{
	static PostProcessEffect_to_buffer = to_buffer;
	static PostProcessEffect_from_buffer = from_buffer;

	/// @var {Real} Gamma value. Default value is 2.2.
	Gamma = _gamma;

	static __uGamma = shader_get_uniform(BBMOD_ShGammaCorrect, "u_fGamma");

	static to_buffer = function (_buffer)
	{
		PostProcessEffect_to_buffer(_buffer);
		buffer_write(_buffer, buffer_f64, Gamma);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		PostProcessEffect_from_buffer(_buffer);
		Gamma = buffer_read(_buffer, buffer_f64);
		return self;
	};

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
