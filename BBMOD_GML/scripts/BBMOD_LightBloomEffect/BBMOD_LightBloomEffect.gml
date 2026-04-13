/// @module PostProcessing

/// @func BBMOD_LightBloomEffect([_threshold[, _knee[, _strength]]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Light bloom (post-processing effect).
///
/// @param {Real} [_threshold] Brightness threshold for bloom. Pixels brighter
/// than this will bloom. Defaults to 1.
/// @param {Real} [_knee] Soft knee width for smooth threshold transition.
/// Higher values create smoother bloom falloff. Defaults to 0.5.
/// @param {Real} [_strength] The strength of the effect. Use values in range
/// 0..1. Defaults to 1.
/* beautify ignore:start */
function BBMOD_LightBloomEffect(_threshold = 1.0, _knee = 0.5, _strength = 1.0): BBMOD_PostProcessEffect() constructor
/* beautify ignore:end */
{
	/// @var {Real} Brightness threshold for bloom. Pixels brighter than this
	/// will bloom. Default value is 1.0.
	Threshold = (_threshold != undefined) ? (is_struct(_threshold) ? -_threshold.X : _threshold) : 1.0;

	/// @var {Real} Soft knee width for smooth threshold transition. Higher
	/// values create smoother bloom falloff. Default value is 0.5.
	Knee = (_knee != undefined) ? (is_struct(_knee) ? _knee.X : _knee) : 0.5;

	/// @var {Real} The strength of the effect. Use values in range 0..1.
	/// Default value is 1.
	Strength = _strength;

	/// @var {Real}
	/// @private
	__levels = 8;

	/// @var {Array<Real>}
	/// @private
	__mipIntensity = array_create(__levels, 1.0);

	/// @var {Array<Id.Surface>}
	/// @private
	__surfaces1 = array_create(__levels, -1);

	/// @var {Array<Id.Surface>}
	/// @private
	__surfaces2 = array_create(__levels, -1);

	static __uThreshold = shader_get_uniform(BBMOD_ShThreshold, "uThreshold");
	static __uKnee = shader_get_uniform(BBMOD_ShThreshold, "uKnee");
	static __uTexelSize = shader_get_uniform(BBMOD_ShThreshold, "uTexelSize");

	static __uTexelDownsampleKaris = shader_get_uniform(BBMOD_ShDownsampleKaris, "uTexel");

	static __uTexelGaussian = shader_get_uniform(BBMOD_ShGaussianBlur, "uTexel");

	static __uTexelUpsample = shader_get_uniform(BBMOD_ShBloomUpsample, "uTexelSize");
	static __uRadiusUpsample = shader_get_uniform(BBMOD_ShBloomUpsample, "uRadius");

	static __uLensDirtTex = shader_get_sampler_index(BBMOD_ShLensDirt, "uLensDirt");
	static __uLensDirtUVs = shader_get_uniform(BBMOD_ShLensDirt, "uLensDirtUVs");
	static __uLensDirtStrength = shader_get_uniform(BBMOD_ShLensDirt, "uLensDirtStrength");

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
		shader_set_uniform_f(__uThreshold, Threshold);
		shader_set_uniform_f(__uKnee, Knee);
		shader_set_uniform_f(__uTexelSize, 1.0 / _width, 1.0 / _height);
		draw_surface_stretched(_surfaceSrc, 0, 0, _width / 2, _height / 2);
		shader_reset();
		surface_reset_target();

		// Downsample
		{
			shader_set(BBMOD_ShDownsampleKaris);

			var i = 1;
			var _w = _width / 4;
			var _h = _height / 4;
			repeat(__levels - 1)
			{
				__surfaces1[@ i] = bbmod_surface_check(__surfaces1[i], _w, _h, _format, false);
				surface_set_target(__surfaces1[i]);
				shader_set_uniform_f(__uTexelDownsampleKaris, 1.0 / _w, 1.0 / _h);
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
		gpu_set_blendmode(bm_add);

		// Progressive upsampling
		shader_set(BBMOD_ShBloomUpsample);
		shader_set_uniform_f(__uRadiusUpsample, 1.0);

		var _smallestMip = __levels - 1;
		while (_smallestMip > 0 && !surface_exists(__surfaces1[_smallestMip]))
		{
			--_smallestMip;
		}

		for (var i = _smallestMip - 1; i >= 0; --i)
		{
			var _w = surface_get_width(__surfaces1[i]);
			var _h = surface_get_height(__surfaces1[i]);
			var _mipIntensity = __mipIntensity[i];

			shader_set_uniform_f(__uTexelUpsample, 1.0 / surface_get_width(__surfaces1[i + 1]), 1.0 / surface_get_height(__surfaces1[i + 1]));
			surface_set_target(__surfaces2[i]);
			draw_surface_stretched(__surfaces1[i + 1], 0, 0, _w, _h);
			surface_reset_target();

			surface_set_target(__surfaces1[i]);
			draw_surface_ext(__surfaces2[i], 0, 0, 1, 1, 0, c_white, _mipIntensity);
			surface_reset_target();
		}

		shader_reset();

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
