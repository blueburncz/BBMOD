/// @module PostProcessing

/// @func BBMOD_ReinhardTonemapEffect()
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Reinhard tonemapping (post-processing effect).
function BBMOD_ReinhardTonemapEffect(): BBMOD_PostProcessEffect() constructor
{
	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShReinhardTonemap);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};
}
