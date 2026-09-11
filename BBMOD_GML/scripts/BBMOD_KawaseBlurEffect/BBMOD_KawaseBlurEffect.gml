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
	static PostProcessEffect_to_buffer = to_buffer;
	static PostProcessEffect_from_buffer = from_buffer;

	/// @var {Array<Real>} An array of offsets for the blur, e.g.
	///`[0, 1, 2, 3]`. Default value is an empty array.
	Offsets = _offsets;

	static __uTexel = shader_get_uniform(BBMOD_ShKawaseBlur, "u_vTexel");
	static __uOffset = shader_get_uniform(BBMOD_ShKawaseBlur, "u_fOffset");

	static to_buffer = function (_buffer)
	{
		PostProcessEffect_to_buffer(_buffer);
		buffer_write(_buffer, buffer_u32, array_length(Offsets));
		for (var i = 0; i < array_length(Offsets); ++i)
		{
			buffer_write(_buffer, buffer_f64, Offsets[i]);
		}
		return self;
	};

	static from_buffer = function (_buffer)
	{
		PostProcessEffect_from_buffer(_buffer);
		var _count = buffer_read(_buffer, buffer_u32);
		if (_count > 100000)
		{
			throw new BBMOD_Exception("Invalid Kawase blur offset count.");
		}
		Offsets = array_create(_count, 0.0);
		for (var i = 0; i < _count; ++i)
		{
			Offsets[i] = buffer_read(_buffer, buffer_f64);
		}
		return self;
	};

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
