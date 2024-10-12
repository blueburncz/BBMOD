/// @module PostProcessing

/// @func BBMOD_KawaseBlurEffect([_offsets])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Kawase blur (post-processing effect).
///
/// @param {Array<Real>} [_offsets] An array of offsets for the blur, e.g.
/// `[0, 1, 2, 3]`. Defaults to an empty array.
function BBMOD_KawaseBlurEffect(_offsets = []): BBMOD_PostProcessEffect() constructor
{
	/// @var {Array<Real>} An array of offsets for the blur, e.g.
	///`[0, 1, 2, 3]`. Default value is an empty array.
	Offsets = _offsets;

	static __uTexel = shader_get_uniform(BBMOD_ShKawaseBlur, "u_vTexel");
	static __uOffset = shader_get_uniform(BBMOD_ShKawaseBlur, "u_fOffset");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		var _offsetCount = array_length(Offsets);
		if (_offsetCount > 0)
		{
			shader_set(BBMOD_ShKawaseBlur);
			shader_set_uniform_f(
				__uTexel,
				1.0 / surface_get_width(_surfaceSrc),
				1.0 / surface_get_height(_surfaceSrc));
			var i = 0;
			repeat(_offsetCount)
			{
				shader_set_uniform_f(__uOffset, Offsets[i++]);
				surface_set_target(_surfaceDest);
				draw_surface(_surfaceSrc, 0, 0);
				surface_reset_target();
				var _temp = _surfaceSrc;
				_surfaceSrc = _surfaceDest;
				_surfaceDest = _temp;
			}
			shader_reset();
		}
		return _surfaceSrc;
	};
}
