/// @func BBMOD_LightBloomEffect([_bias[, _scale]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Light bloom (post-processing effect).
///
/// @param {Struct.BBMOD_Vec3} [_bias]
/// @param {Struct.BBMOD_Vec3} [_scale]
function BBMOD_LightBloomEffect(_bias=undefined, _scale=undefined)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Bias = _bias ?? new BBMOD_Vec3(0.8);

	/// @var {Struct.BBMOD_Vec3}
	Scale = _scale ?? new BBMOD_Vec3(1.0);

	__levels = 8;
	__surfaces1 = array_create(__levels, -1);
	__surfaces2 = array_create(__levels, -1);

	__uBias = shader_get_uniform(BBMOD_ShThreshold, "u_vBias");
	__uScale = shader_get_uniform(BBMOD_ShThreshold, "u_vScale");

	__uTexel = shader_get_uniform(BBMOD_ShKawaseBlur, "u_vTexel");
	__uOffset = shader_get_uniform(BBMOD_ShKawaseBlur, "u_fOffset");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		var _width = surface_get_width(_surfaceSrc);
		var _height = surface_get_height(_surfaceSrc);

		var _surfaceFormat = bbmod_hdr_is_supported()
			? surface_rgba16float : surface_rgba8unorm;

		// Threshold
		__surfaces1[@ 0] = bbmod_surface_check(__surfaces1[0], _width / 2, _height / 2, _surfaceFormat, false);
		__surfaces2[@ 0] = bbmod_surface_check(__surfaces2[0], _width / 2, _height / 2, _surfaceFormat, false);
		surface_set_target(__surfaces1[0]);
		shader_set(BBMOD_ShThreshold);
		shader_set_uniform_f(__uBias, Bias.X, Bias.Y, Bias.Z);
		shader_set_uniform_f(__uScale, Scale.X, Scale.Y, Scale.Z);
		draw_surface_stretched(_surfaceSrc, 0, 0, _width / 2, _height / 2);
		shader_reset();
		surface_reset_target();

		// Downsample + Kawase
		{
			shader_set(BBMOD_ShKawaseBlur);
			shader_set_uniform_f(__uOffset, 0.0);

			var i = 1;
			var _w = _width / 4;
			var _h = _height / 4;
			repeat (__levels - 1)
			{
				__surfaces1[@ i] = bbmod_surface_check(__surfaces1[i], _w, _h, _surfaceFormat, false);
				surface_set_target(__surfaces1[i]);
				shader_set_uniform_f(__uTexel, 1.0 / _w, 1.0 / _h);
				draw_surface_stretched(__surfaces1[i - 1], 0, 0, _w, _h);
				surface_reset_target();
				_w = _w >> 1;
				_h = _h >> 1;
				if (_w == 0 || _h == 0) break;
				++i;
			}

			shader_reset();
		}

		// Two-pass Gaussian
		{
			shader_set(BBMOD_ShGaussianBlur);

			var _uTexelGaussian = shader_get_uniform(BBMOD_ShGaussianBlur, "u_vTexel");

			var i = 0;
			var _w = _width / 2;
			var _h = _height / 2;
			repeat (__levels)
			{
				__surfaces2[@ i] = bbmod_surface_check(__surfaces2[i], _w, _h, _surfaceFormat, false);

				// Horizontal
				shader_set_uniform_f(_uTexelGaussian, 1.0 / _w, 0.0);
				surface_set_target(__surfaces2[i]);
				draw_surface_stretched(__surfaces1[i], 0, 0, _w, _h);
				surface_reset_target();

				// Vertical
				shader_set_uniform_f(_uTexelGaussian, 0.0, 1.0 / _h);
				surface_set_target(__surfaces1[i]);
				draw_surface_stretched(__surfaces2[i], 0, 0, _w, _h);
				surface_reset_target();

				_w = _w >> 1;
				_h = _h >> 1;
				if (_w == 0 || _h == 0) break;
				++i;
			}

			shader_reset();
		}

		// Combine
		surface_set_target(_surfaceDest);
		if (keyboard_check(ord("Q")))
		{
			draw_clear(c_black);
		}
		else
		{
			draw_surface(_surfaceSrc, 0, 0);
		}

		gpu_push_state();
		gpu_set_blendenable(true);
		gpu_set_blendmode(bm_add);
		for (var i = 0; i < __levels; ++i)
		{
			if (surface_exists(__surfaces1[i]))
			{
				draw_surface_stretched(__surfaces1[i], 0, 0, _width, _height);
			}
		}
		gpu_pop_state();
		surface_reset_target();

		return _surfaceDest;
	};

	static destroy = function ()
	{
		for (var i = 0; i < __levels; ++i)
		{
			if (surface_exists(__surfaces1[i]))
			{
				surface_free(__surfaces1[i]);
			}

			if (surface_exists(__surfaces2[i]))
			{
				surface_free(__surfaces2[i]);
			}
		}

		return undefined;
	};
}
