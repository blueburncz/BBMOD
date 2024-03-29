/// @module PostProcessing

/// @func BBMOD_LensDistortionEffect([_strength[, _zoom]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Barell and pincushion lens distortion (post-processing effect).
///
/// @param {Real} [_strength] The strength of the effect. Use positive values
/// for barell distortion and negative for pincushion distortion. Defaults to
/// 0 (no distortion).
/// @param {Real} [_zoom] Zoom in into the surface. Must be greater than 0!
/// Defaults to 1 (no zoom).
function BBMOD_LensDistortionEffect(_strength=0.0, _zoom=1.0)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Real} The strength of the effect. Use positive values for barell
	/// distortion and negative for pincushion distortion. Default value is 0
	/// (no distortion).
	Strength = _strength;

	/// @var {Real} Zoom in into the surface. Must be greater than 0! Default
	/// value is 1 (no zoom).
	Zoom = _zoom;

	static __uStrength = shader_get_uniform(BBMOD_ShLensDistortion, "u_fStrength");
	static __uScale    = shader_get_uniform(BBMOD_ShLensDistortion, "u_fScale");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShLensDistortion);
		shader_set_uniform_f(__uStrength, Strength);
		shader_set_uniform_f(__uScale, 1.0 / Zoom);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};
}
