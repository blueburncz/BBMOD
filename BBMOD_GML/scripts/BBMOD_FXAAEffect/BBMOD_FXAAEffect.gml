/// @func BBMOD_FXAAEffect()
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Fast approximate anti-aliasing (post-processing effect).
function BBMOD_FXAAEffect()
	: BBMOD_PostProcessEffect() constructor
{
	__uTexelVS = shader_get_uniform(BBMOD_ShFXAA, "u_vTexelVS");
	__uTexelPS = shader_get_uniform(BBMOD_ShFXAA, "u_vTexelPS");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		var _texelWidth = 1.0 / surface_get_width(_surfaceSrc);
		var _texelHeight = 1.0 / surface_get_height(_surfaceSrc);

		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShFXAA);
		shader_set_uniform_f(__uTexelVS, _texelWidth, _texelHeight);
		shader_set_uniform_f(__uTexelPS, _texelWidth, _texelHeight);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();

		return self;
	};
}
