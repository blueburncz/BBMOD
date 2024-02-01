/// @func BBMOD_VignetteEffect([_strength[, _color]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Vignette (post-processing effect).
///
/// @param {Real} [_strength] The strength of the effect. Defaults to 1.
/// @param {Constant.Color} [_color] The color of the effect. Defaults to
/// `c_black`.
function BBMOD_VignetteEffect(_strength=1.0, _color=c_black)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Real} The strength of the effect. Default value is 1.
	Strength = _strength;

	/// @var {Constant.Color} The color of the effect. Default value is to
	/// `c_black`.
	Color = _color;

	__uVignette = shader_get_uniform(BBMOD_ShVignette, "u_fVignette");
	__uVignetteColor = shader_get_uniform(BBMOD_ShVignette, "u_vVignetteColor");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		var _texelWidth = 1.0 / surface_get_width(_surfaceSrc);
		var _texelHeight = 1.0 / surface_get_height(_surfaceSrc);

		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShVignette);
		shader_set_uniform_f(__uVignette, Strength);
		shader_set_uniform_f(
			__uVignetteColor,
			color_get_red(Color) / 255.0,
			color_get_green(Color) / 255.0,
			color_get_blue(Color) / 255.0);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();

		return self;
	};
}
