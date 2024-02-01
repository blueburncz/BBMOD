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
	Bias = _bias ?? new BBMOD_Vec3(0.7);

	/// @var {Struct.BBMOD_Vec3}
	Scale = _scale ?? new BBMOD_Vec3(2.0);

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

		gpu_push_state();
		gpu_set_blendenable(true);

		// Threshold
		__surfaces[@ 0] = bbmod_surface_check(__surfaces[0], _width / 2, _height / 2, surface_rgba8unorm, false);
		surface_set_target(__surfaces[0]);
		shader_set(BBMOD_ShThreshold);
		shader_set_uniform_f(__uBias, Bias.X, Bias.Y, Bias.Z);
		shader_set_uniform_f(__uScale, Scale.X, Scale.Y, Scale.Z);
		draw_surface_stretched(_surfaceSrc, 0, 0, _width / 2, _height / 2);
		shader_reset();
		surface_reset_target();

		// Blur
		shader_set(BBMOD_ShKawaseBlur);
		shader_set_uniform_f(__uOffset, 0.0);

		var i = 1;
		var _w = _width / 4;
		var _h = _height / 4;
		repeat (__levels - 1)
		{
			__surfaces[@ i] = bbmod_surface_check(__surfaces[i], _w, _h, surface_rgba8unorm, false);
			surface_set_target(__surfaces[i]);
			shader_set_uniform_f(__uTexel, 1.0 / _w, 1.0 / _h);
			draw_surface_stretched(__surfaces[i - 1], 0, 0, _w, _h);
			surface_reset_target();
			_w = _w >> 1;
			_h = _h >> 1;
			if (_w == 0 || _h == 0) break;
			++i;
		}

		shader_reset();

		// Combine
		surface_set_target(_surfaceDest);
		draw_surface(_surfaceSrc, 0, 0);
		gpu_set_blendmode(bm_add);

		for (var i = 1; i < __levels; ++i)
		{
			if (surface_exists(__surfaces[i]))
			{
				draw_surface_stretched(__surfaces[i], 0, 0, _width, _height);
			}
		}

		surface_reset_target();

		gpu_pop_state();

		return _surfaceDest;
	};

	static destroy = function ()
	{
		// TODO: Free surfaces
		return undefined;
	};
}
