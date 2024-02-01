/// @func BBMOD_MonochromeEffect([_strength[, _color]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Monochrome (post-processing effect).
///
/// @param {Real} [_strength] The strength of the effect. Defaults to 1.
/// @param {Constant.Color} [_color] The color of the effect. Defaults to
/// `c_white`.
function BBMOD_MonochromeEffect(_strength=1.0, _color=c_white)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Real} The strength of the effect. Default value is 1.
	Strength = _strength;

	/// @var {Constant.Color} The color of the effect. Default value is to
	/// `c_white`.
	Color = _color;

	__uStrength = shader_get_uniform(BBMOD_ShMonochrome, "u_fStrength");
	__uColor = shader_get_uniform(BBMOD_ShMonochrome, "u_vColor");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		var _texelWidth = 1.0 / surface_get_width(_surfaceSrc);
		var _texelHeight = 1.0 / surface_get_height(_surfaceSrc);

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

		return self;
	};
}
