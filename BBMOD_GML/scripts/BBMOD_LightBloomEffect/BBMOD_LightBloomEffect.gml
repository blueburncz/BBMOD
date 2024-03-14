/// @module PostProcessing

/// @func BBMOD_LightBloomEffect([_bias[, _scale[, _hdr]]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Light bloom (post-processing effect).
///
/// @param {Struct.BBMOD_Vec3} [_bias]
/// @param {Struct.BBMOD_Vec3} [_scale]
/// @param {Bool} [_hdr]
function BBMOD_LightBloomEffect(_bias=undefined, _scale=undefined, _hdr=false)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Bias = _bias ?? new BBMOD_Vec3(0.5);

	/// @var {Struct.BBMOD_Vec3}
	Scale = _scale ?? new BBMOD_Vec3(1.0);

	/// @var {Bool}
	HDR = _hdr;

	__levels = 8;
	__surfaces1 = array_create(__levels, -1);
	__surfaces2 = array_create(__levels, -1);

	static __uBias = shader_get_uniform(BBMOD_ShThreshold, "u_vBias");
	static __uScale = shader_get_uniform(BBMOD_ShThreshold, "u_vScale");

	static __uTexelKawase = shader_get_uniform(BBMOD_ShKawaseBlur, "u_vTexel");
	static __uOffset = shader_get_uniform(BBMOD_ShKawaseBlur, "u_fOffset");

	static __uTexelGaussian = shader_get_uniform(BBMOD_ShGaussianBlur, "u_vTexel");

	static __uLensDirtTex = shader_get_sampler_index(BBMOD_ShLensDirt, "u_texLensDirt");
	static __uLensDirtUVs = shader_get_uniform(BBMOD_ShLensDirt, "u_vLensDirtUVs");
	static __uLensDirtStrength = shader_get_uniform(BBMOD_ShLensDirt, "u_fLensDirtStrength");

	static __draw_ldr = function (_surfaceDest, _surfaceSrc)
	{
		var _width = surface_get_width(_surfaceSrc);
		var _height = surface_get_height(_surfaceSrc);

		// Threshold
		__surfaces1[@ 0] = bbmod_surface_check(__surfaces1[0], _width / 2, _height / 2, surface_rgba8unorm, false);
		__surfaces2[@ 0] = bbmod_surface_check(__surfaces2[0], _width / 2, _height / 2, surface_rgba8unorm, false);
		surface_set_target(__surfaces1[0]);
		shader_set(BBMOD_ShThreshold);
		shader_set_uniform_f(__uBias, Bias.X, Bias.Y, Bias.Z);
		shader_set_uniform_f(__uScale, Scale.X, Scale.Y, Scale.Z);
		draw_surface_stretched(_surfaceSrc, 0, 0, _width / 2, _height / 2);
		shader_reset();
		surface_reset_target();

		// Kawase
		shader_set(BBMOD_ShKawaseBlur);
		shader_set_uniform_f(__uTexelKawase, 1.0 / (_width / 2.0), 1.0 / (_height / 2.0));

		var _surSrc = __surfaces1[0];
		var _surDest = __surfaces2[0];
		var i = 0;
		repeat (__levels)
		{
			surface_set_target(_surDest);
			shader_set_uniform_f(__uOffset, i++);
			draw_surface(_surSrc, 0, 0);
			surface_reset_target();

			var _temp = _surSrc;
			_surSrc = _surDest;
			_surDest = _temp;
		}

		shader_reset();

		// Combine
		surface_set_target(_surfaceDest);
		draw_surface(_surfaceSrc, 0, 0);
		gpu_push_state();
		gpu_set_blendenable(true);
		gpu_set_blendmode(bm_add);
		draw_surface_stretched(_surSrc, 0, 0, _width, _height);
		gpu_pop_state();
		surface_reset_target();

		return _surfaceDest;
	};

	static __draw_hdr = function (_surfaceDest, _surfaceSrc)
	{
		var _width = surface_get_width(_surfaceSrc);
		var _height = surface_get_height(_surfaceSrc);

		// Threshold
		__surfaces1[@ 0] = bbmod_surface_check(__surfaces1[0], _width / 2, _height / 2, surface_rgba16float, false);
		__surfaces2[@ 0] = bbmod_surface_check(__surfaces2[0], _width / 2, _height / 2, surface_rgba16float, false);
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
				__surfaces1[@ i] = bbmod_surface_check(__surfaces1[i], _w, _h, surface_rgba16float, false);
				surface_set_target(__surfaces1[i]);
				shader_set_uniform_f(__uTexelKawase, 1.0 / _w, 1.0 / _h);
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

			var i = 0;
			var _w = _width / 2;
			var _h = _height / 2;
			repeat (__levels)
			{
				__surfaces2[@ i] = bbmod_surface_check(__surfaces2[i], _w, _h, surface_rgba16float, false);

				// Horizontal
				shader_set_uniform_f(__uTexelGaussian, 1.0 / _w, 0.0);
				surface_set_target(__surfaces2[i]);
				draw_surface_stretched(__surfaces1[i], 0, 0, _w, _h);
				surface_reset_target();

				// Vertical
				shader_set_uniform_f(__uTexelGaussian, 0.0, 1.0 / _h);
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

		gpu_push_state();
		gpu_set_blendenable(true);

		// Combine into one
		gpu_set_blendmode(bm_add);
		surface_set_target(__surfaces1[0]);
		for (var i = 1; i < __levels; ++i)
		{
			if (surface_exists(__surfaces1[i]))
			{
				draw_surface_stretched(__surfaces1[i], 0, 0, _width, _height);
			}
		}
		surface_reset_target();

		// Overlay
		surface_set_target(_surfaceDest);
		gpu_set_blendmode(bm_normal);
		draw_surface(_surfaceSrc, 0, 0);
		shader_set(BBMOD_ShLensDirt);
		texture_set_stage(__uLensDirtTex, PostProcessor.LensDirt);
		var _uvs = texture_get_uvs(PostProcessor.LensDirt);
		shader_set_uniform_f(__uLensDirtUVs, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
		shader_set_uniform_f(__uLensDirtStrength, PostProcessor.LensDirtStrength);
		gpu_set_blendmode(bm_add);
		draw_surface_stretched(__surfaces1[0], 0, 0, _width, _height);
		shader_reset();
		surface_reset_target();

		gpu_pop_state();

		return _surfaceDest;
	};

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		if (HDR && bbmod_hdr_is_supported())
		{
			return __draw_hdr(_surfaceDest, _surfaceSrc);
		}
		return __draw_ldr(_surfaceDest, _surfaceSrc);
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
