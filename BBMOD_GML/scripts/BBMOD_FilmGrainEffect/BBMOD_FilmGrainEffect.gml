/// @module PostProcessing

/// @func BBMOD_FilmGrainEffect([_strength])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Film grain (post-processing effect).
///
/// @param {Real} [_strength] The strength of the effect. Defaults to 0.1.
function BBMOD_FilmGrainEffect(_strength=0.1)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Real} The strength of the effect. Default value is 0.1.
	Strength = _strength;

	static __uStrength = shader_get_uniform(BBMOD_ShFilmGrain, "u_fStrength");
	static __uTime     = shader_get_uniform(BBMOD_ShFilmGrain, "u_fTime");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShFilmGrain);
		shader_set_uniform_f(__uStrength, Strength);
		shader_set_uniform_f(__uTime, dsin(current_time) * 0.5 + 0.5);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};
}
