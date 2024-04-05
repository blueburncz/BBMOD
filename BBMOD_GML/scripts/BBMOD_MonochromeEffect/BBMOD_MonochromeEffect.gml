/// @module PostProcessing

/// @func BBMOD_MonochromeEffect([_strength[, _color]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Monochrome (post-processing effect).
///
/// @param {Real} [_strength] The strength of the effect. Use values greater or
/// equal to 0. Defaults to 1.
/// @param {Constant.Color} [_color] The color of the effect. Defaults to
/// `c_white`.
function BBMOD_MonochromeEffect(_strength=1.0, _color=c_white)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Real} The strength of the effect. Use values greater or equal to
	/// 0. Default value is 1.
	Strength = _strength;

	/// @var {Constant.Color} The color of the effect. Default value is to
	/// `c_white`.
	Color = _color;

	static __uStrength = shader_get_uniform(BBMOD_ShMonochrome, "u_fStrength");
	static __uColor    = shader_get_uniform(BBMOD_ShMonochrome, "u_vColor");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		if (Strength <= 0.0)
		{
			return _surfaceSrc;
		}
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShMonochrome);
		shader_set_uniform_f(__uStrength, Strength);
		shader_set_uniform_f(
			__uColor,
			color_get_red(Color) / 255.0,
			color_get_green(Color) / 255.0,
			color_get_blue(Color) / 255.0);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};
}
