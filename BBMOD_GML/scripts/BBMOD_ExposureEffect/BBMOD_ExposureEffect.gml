/// @module PostProcessing

/// @func BBMOD_ExposureEffect()
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Applies camera exposure (post-processing effect).
///
/// @see BBMOD_BaseCamera.Exposure
function BBMOD_ExposureEffect()
	: BBMOD_PostProcessEffect() constructor
{
	static __uExposure = shader_get_uniform(BBMOD_ShExposure, "u_fExposure");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShExposure);
		shader_set_uniform_f(__uExposure, bbmod_camera_get_exposure());
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};
}
