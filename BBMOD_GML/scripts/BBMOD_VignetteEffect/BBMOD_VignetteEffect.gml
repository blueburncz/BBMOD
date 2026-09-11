/// @module PostProcessing

/// @func BBMOD_VignetteEffect([_strength[, _color]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Vignette (post-processing effect).
///
/// @param {Real} [_strength] The strength of the effect. Defaults to 1.
/// @param {Constant.Color} [_color] The color of the effect. Defaults to
/// `c_black`.
function BBMOD_VignetteEffect(_strength = 1.0, _color = c_black): BBMOD_PostProcessEffect() constructor
{
	static PostProcessEffect_to_buffer = to_buffer;
	static PostProcessEffect_from_buffer = from_buffer;

	/// @var {Real} The strength of the effect. Default value is 1.
	Strength = _strength;

	/// @var {Constant.Color} The color of the effect. Default value is to
	/// `c_black`.
	Color = _color;

	static __uStrength = shader_get_uniform(BBMOD_ShVignette, "u_fStrength");
	static __uColor = shader_get_uniform(BBMOD_ShVignette, "u_vColor");

	static to_buffer = function (_buffer)
	{
		PostProcessEffect_to_buffer(_buffer);
		buffer_write(_buffer, buffer_f64, Strength);
		buffer_write(_buffer, buffer_u32, Color);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		PostProcessEffect_from_buffer(_buffer);
		Strength = buffer_read(_buffer, buffer_f64);
		Color = buffer_read(_buffer, buffer_u32);
		return self;
	};

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		if (Strength <= 0.0)
		{
			return _surfaceSrc;
		}
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShVignette);
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
