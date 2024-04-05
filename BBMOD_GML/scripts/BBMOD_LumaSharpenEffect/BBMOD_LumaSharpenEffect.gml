/// @module PostProcessing

/// @func BBMOD_LumaSharpenEffect([_strength[, _clamp[, _offset]]])
///
/// @extends BBMOD_PostProcessEffect 
///
/// @desc Luma sharpen (post-processing effect).
///
/// @param {Real} [_strength] The strength of the effect. Defaults to 1.
/// @param {Real} [_clamp] Clamping of the effect. Defaults to 1.
/// @param {Real} [_offset] High-pass offset (in pixels). Defaults to 1.
function BBMOD_LumaSharpenEffect(_strength=1.0, _clamp=1.0, _offset=1.0)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Real} The strength of the effect. Default value is 1.
	Strength = _strength;

	/// @var {Real} Clamping of the effect. Default value is 1.
	Clamp = _clamp;

	/// @var {Real} High-pass offset (in pixels). Default value is 1.
	Offset = _offset;

	static __uTexel    = shader_get_uniform(BBMOD_ShLumaSharpen, "u_vTexel");
	static __uStrength = shader_get_uniform(BBMOD_ShLumaSharpen, "u_fStrength");
	static __uClamp    = shader_get_uniform(BBMOD_ShLumaSharpen, "u_fClamp");
	static __uOffset   = shader_get_uniform(BBMOD_ShLumaSharpen, "u_fOffset");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		if (Strength <= 0.0)
		{
			return _surfaceSrc;
		}
		var _texelWidth = 1.0 / surface_get_width(_surfaceSrc)
		var _texelHeight = 1.0 / surface_get_height(_surfaceSrc);
		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShLumaSharpen);
		shader_set_uniform_f(__uTexel, _texelWidth, _texelHeight);
		shader_set_uniform_f(__uStrength, Strength);
		shader_set_uniform_f(__uClamp, Clamp);
		shader_set_uniform_f(__uOffset, Offset);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		surface_reset_target();
		return _surfaceDest;
	};
}
