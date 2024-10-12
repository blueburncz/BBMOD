/// @module PostProcessing

/// @func BBMOD_LightBloomEffect([_bias[, _scale[, _strength]]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Light bloom (post-processing effect).
///
/// @param {Struct.BBMOD_Vec3} [_bias] A value added to RGB channels before the
/// light bloom effect is applied. Defaults to `(-1, -1, -1)` if `undefined`.
/// @param {Struct.BBMOD_Vec3} [_scale] A value that the RGB channels are
/// multiplied by before the light bloom effect is applied. Defaults to
/// `(1, 1, 1)` if `undefined`.
/// @param {Real} [_strength] The strength of the effect. Use values in range
/// 0..1. Defaults to 1.
function BBMOD_LightBloomEffect(_bias = undefined, _scale = undefined, _strength = 1.0): BBMOD_PostProcessEffect
	() constructor
	{
		/// @var {Struct.BBMOD_Vec3} A value added to RGB channels before the light
		/// bloom effect is applied. Default value is `(-1, -1, -1)`.
		Bias = _bias ?? new BBMOD_Vec3(-1.0);

		/// @var {Struct.BBMOD_Vec3} A value that the RGB channels are multiplied by
		/// before the light bloom effect is applied. Default value is `(1, 1, 1)`.
		Scale = _scale ?? new BBMOD_Vec3(1.0);

		/// @var {Real} The strength of the effect. Use values in range 0..1.
		/// Default value is 1.
		Strength = _strength;

		/// @var {Real}
		__levels = 8;

		/// @var {Array<Id.Surface>}
		/// @private
		__surfaces1 = array_create(__levels, -1);

		/// @var {Array<Id.Surface>}
		/// @private
		__surfaces2 = array_create(__levels, -1);

		static __uBias = shader_get_uniform(BBMOD_ShThreshold, "u_vBias");
		static __uScale = shader_get_uniform(BBMOD_ShThreshold, "u_vScale");

		static __uTexelKawase = shader_get_uniform(BBMOD_ShKawaseBlur, "u_vTexel");
		static __uOffset = shader_get_uniform(BBMOD_ShKawaseBlur, "u_fOffset");

		static __uTexelGaussian = shader_get_uniform(BBMOD_ShGaussianBlur, "u_vTexel");

		static __uLensDirtTex = shader_get_sampler_index(BBMOD_ShLensDirt, "u_texLensDirt");
		static __uLensDirtUVs = shader_get_uniform(BBMOD_ShLensDirt, "u_vLensDirtUVs");
		static __uLensDirtStrength = shader_get_uniform(BBMOD_ShLensDirt, "u_fLensDirtStrength");

		static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
		{
			if (Strength <= 0.0)
			{
				return _surfaceSrc;
			}

			var _width = surface_get_width(_surfaceSrc);
			var _height = surface_get_height(_surfaceSrc);
			var _format = bbmod_hdr_is_supported() ? surface_rgba16float : surface_rgba8unorm;

			// Threshold
			__surfaces1[@ 0] = bbmod_surface_check(__surfaces1[0], _width / 2, _height / 2, _format, false);
			__surfaces2[@ 0] = bbmod_surface_check(__surfaces2[0], _width / 2, _height / 2, _format, false);
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
				repeat(__levels - 1)
				{
					__surfaces1[@ i] = bbmod_surface_check(__surfaces1[i], _w, _h, _format, false);
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
				repeat(__levels)
				{
					__surfaces2[@ i] = bbmod_surface_check(__surfaces2[i], _w, _h, _format, false);

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
					draw_surface_stretched(__surfaces1[i], 0, 0, _width / 2, _height / 2);
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
			draw_surface_stretched_ext(__surfaces1[0], 0, 0, _width, _height, c_white, Strength);
			shader_reset();
			surface_reset_target();

			gpu_pop_state();

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
