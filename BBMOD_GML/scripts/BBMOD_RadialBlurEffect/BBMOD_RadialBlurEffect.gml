/// @func BBMOD_RadialBlurEffect([_origin[, _radius[, _strength[, _step]]]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Radial blur (post-processing effect).
///
/// @param {Struct.BBMOD_Vec2} [_origin] The origin of the blur. Defaults to
/// `(0.5, 0.5)` if `undefined`.
/// @param {Real} [_radius] The radius of area that is in focus. Use values in
/// range 0..1. Defaults to 0.5.
/// @param {Real} [_strength] The strength of the blur. Defaults to 1.
/// @param {Real} [_step] Step size. Use values in range (0; 1]. Defaults to
/// 1/8.
function BBMOD_RadialBlurEffect(_origin=undefined, _radius=0.5, _strength=1.0, _step=0.125)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Struct.BBMOD_Vec2} The origin of the blur. Default value is
	/// `(0.5, 0.5)` (the middle of the screen).
	Origin = _origin ?? new BBMOD_Vec2(0.5);

	/// @var {Real} The radius of area that is in focus. Use values in range
	/// 0..1. Default value is 0.5.
	Radius = _radius;

	/// @var {Real} The strength of the blur. Default value is 1.
	Strength = _strength;

	/// @var {Real} Step size. Use values in range (0; 1]. Default value is
	/// 1/8.
	Step = _step;

	__uTexel = shader_get_uniform(BBMOD_ShRadialBlur, "u_vTexel");
	__uOrigin = shader_get_uniform(BBMOD_ShRadialBlur, "u_vOrigin");
	__uRadius = shader_get_uniform(BBMOD_ShRadialBlur, "u_fRadius");
	__uStrength = shader_get_uniform(BBMOD_ShRadialBlur, "u_fStrength");
	__uStep = shader_get_uniform(BBMOD_ShRadialBlur, "u_fStep");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		var _texelWidth = 1.0 / surface_get_width(_surfaceSrc)
		var _texelHeight = 1.0 / surface_get_height(_surfaceSrc);

		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShRadialBlur);
		shader_set_uniform_f(__uTexel, _texelWidth, _texelHeight);
		shader_set_uniform_f(__uOrigin, Origin.X, Origin.Y);
		shader_set_uniform_f(__uRadius, Radius);
		shader_set_uniform_f(__uStrength, Strength);
		shader_set_uniform_f(__uStep, Step);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();

		return self;
	};
}
