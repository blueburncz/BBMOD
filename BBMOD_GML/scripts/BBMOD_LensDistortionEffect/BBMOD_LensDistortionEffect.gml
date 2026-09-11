/// @module PostProcessing

/// @func BBMOD_LensDistortionEffect([_strength[, _zoom]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Barrel and pincushion lens distortion (post-processing effect).
///
/// @param {Real} [_strength] The strength of the effect. Use positive values
/// for barrel distortion and negative for pincushion distortion. Defaults to
/// 0 (no distortion).
/// @param {Real} [_zoom] Zoom in into the surface. Must be greater than 0!
/// Defaults to 1 (no zoom).
function BBMOD_LensDistortionEffect(_strength = 0.0, _zoom = 1.0): BBMOD_PostProcessEffect() constructor
{
	static PostProcessEffect_to_buffer = to_buffer;
	static PostProcessEffect_from_buffer = from_buffer;

	/// @var {Real} The strength of the effect. Use positive values for barrel
	/// distortion and negative for pincushion distortion. Default value is 0
	/// (no distortion).
	Strength = _strength;

	/// @var {Real} Zoom in into the surface. Must be greater than 0! Default
	/// value is 1 (no zoom).
	Zoom = _zoom;

	static __uStrength = shader_get_uniform(BBMOD_ShLensDistortion, "u_fStrength");
	static __uScale = shader_get_uniform(BBMOD_ShLensDistortion, "u_fScale");

	static to_buffer = function (_buffer)
	{
		PostProcessEffect_to_buffer(_buffer);
		buffer_write(_buffer, buffer_f64, Strength);
		buffer_write(_buffer, buffer_f64, Zoom);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		PostProcessEffect_from_buffer(_buffer);
		Strength = buffer_read(_buffer, buffer_f64);
		Zoom = buffer_read(_buffer, buffer_f64);
		return self;
	};

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		if (Strength == 0.0)
		{
			return _surfaceSrc;
		}
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
