/// @module PostProcessing

/// @func BBMOD_ExposureEffect([_exposure])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Applies exposure (post-processing effect).
///
/// @param {Real, Undefined} [_exposure] The exposure value or `undefined` to
/// apply the current camera's exposure value. Defaults to `undefined`.
///
/// @see BBMOD_BaseCamera.Exposure
function BBMOD_ExposureEffect(_exposure = undefined): BBMOD_PostProcessEffect() constructor
{
	/// @var {Real, Undefined} The exposure value or `undefined` to apply the
	/// current camera's exposure value. Default value is `undefined`.
	/// @see BBMOD_BaseCamera.Exposure
	Exposure = _exposure;

	static __uExposure = shader_get_uniform(BBMOD_ShExposure, "u_fExposure");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		var _exposure = Exposure ?? bbmod_camera_get_exposure();
		if (_exposure == 1.0)
		{
			return _surfaceSrc;
		}
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShExposure);
		shader_set_uniform_f(__uExposure, _exposure);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};
}
