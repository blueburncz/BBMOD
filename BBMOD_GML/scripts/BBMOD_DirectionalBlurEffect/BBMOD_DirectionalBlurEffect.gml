/// @func BBMOD_DirectionalBlurEffect([_vector[, _step]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Directional blur (post-processing effect).
///
/// @param {Struct.BBMOD_Vec2} [_vector] The vector to blur along. Defaults to
/// `(0, 0)` if `undefined`.
/// @param {Real} [_step] Step size. Use values in range (0; 1]. Defaults to
/// 1/8.
function BBMOD_DirectionalBlurEffect(_vector=undefined, _step=0.125)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Struct.BBMOD_Vec2} The vector to blur along. Default value is
	/// `(0, 0)`.
	Vector = _vector ?? new BBMOD_Vec2();

	/// @var {Real} Step size. Use values in range (0; 1]. Default value is
	/// 1/8.
	Step = _step;

	__uVector = shader_get_uniform(BBMOD_ShDirectionalBlur, "u_vVector");
	__uStep = shader_get_uniform(BBMOD_ShDirectionalBlur, "u_fStep");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		var _texelWidth = 1.0 / surface_get_width(_surfaceSrc)
		var _texelHeight = 1.0 / surface_get_height(_surfaceSrc);

		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShDirectionalBlur);
		shader_set_uniform_f(__uVector, Vector.X * _texelWidth, Vector.Y * _texelHeight);
		shader_set_uniform_f(__uStep, (Step > 0.0) ? Step : 1.0);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();

		return self;
	};
}
