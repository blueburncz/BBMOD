/// @module PostProcessing

/// @func BBMOD_SunShaftsEffect([_lightDir[, _radius[, _strength[, _step]]]])
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Sun shafts (post-processing effect).
///
/// @param {Struct.BBMOD_Vec3} [_lightDir]
function BBMOD_SunShaftsEffect(_lightDir=undefined)
	: BBMOD_PostProcessEffect() constructor
{
	/// @var {Struct.BBMOD_Vec3} The direction in which the light is coming.
	LightDirection = _lightDir;

	/// @var {Real} The size of the sun, relative to the screen size (i.e. 1
	/// is the full screen, 0.5 is the half of the screen etc.). Default value
	/// is 0.1.
	Radius = 0.1;

	/// @var {Struct.BBMOD_Color} Controls the color and the intensity (via
	/// alpha) of the effect. Default value is {@link BBMOD_C_WHITE}.
	Color = BBMOD_C_WHITE;

	/// @var {Real} The size of the blur. Default value is 100.
	BlurSize = 100;

	/// @var {Real} Used to control the quality of the effect. Use values
	/// greater than 0 and smaller than 1. The smaller the value, the higher the
	/// quality. Default value is 0.01 (high quality).
	BlurStep = 0.01;

	/// @var {Constant.BlendMode} The blend mode used to combine the sun shafts
	/// with the scene. Good options are for example `bm_add` (default) and
	/// `bm_max`.
	BlendMode = bm_add;

	/// @var {Id.Surface}
	/// @private
	__surWork1 = -1;

	/// @var {Id.Surface}
	/// @private
	__surWork2 = -1;

	static __uTexel = shader_get_uniform(BBMOD_ShRadialBlur, "u_vTexel");
	static __uOrigin = shader_get_uniform(BBMOD_ShRadialBlur, "u_vOrigin");
	static __uRadius = shader_get_uniform(BBMOD_ShRadialBlur, "u_fRadius");
	static __uStrength = shader_get_uniform(BBMOD_ShRadialBlur, "u_fStrength");
	static __uStep = shader_get_uniform(BBMOD_ShRadialBlur, "u_fStep");

	static __uLightPos = shader_get_uniform(BBMOD_ShSunShaftMask, "u_vLightPos");
	static __uAspect = shader_get_uniform(BBMOD_ShSunShaftMask, "u_vAspect");
	static __uMaskRadius = shader_get_uniform(BBMOD_ShSunShaftMask, "u_fRadius");
	static __uColor = shader_get_uniform(BBMOD_ShSunShaftMask, "u_vColor");

	static __uLensDirtTex = shader_get_sampler_index(BBMOD_ShLensDirt, "u_texLensDirt");
	static __uLensDirtUVs = shader_get_uniform(BBMOD_ShLensDirt, "u_vLensDirtUVs");
	static __uLensDirtStrength = shader_get_uniform(BBMOD_ShLensDirt, "u_fLensDirtStrength");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		if (LightDirection == undefined || _depth == undefined)
		{
			return _surfaceDest;
		}

		var _camera = global.__bbmodCameraCurrent;
		if (_camera == undefined)
		{
			return _surfaceDest;
		}

		var _rect = PostProcessor.Rect;
		var _screenWidth = _rect.Width;
		var _screenHeight = _rect.Height;
		var _screenPos = _camera.world_to_screen(
			new BBMOD_Vec4(-LightDirection.X, -LightDirection.Y, -LightDirection.Z, 0.0),
			_screenWidth, _screenHeight);

		if (_screenPos == undefined)
		{
			return _surfaceDest;
		}

		_screenPos.X *= 0.5;
		_screenPos.Y *= 0.5;
		var _width = surface_get_width(_surfaceSrc) / 2;
		var _height = surface_get_height(_surfaceSrc) / 2;
		var _texelWidth = 1.0 / _width;
		var _texelHeight = 1.0 / _height;

		var _format = bbmod_hdr_is_supported() ? surface_rgba16float : surface_rgba8unorm;
		__surWork1 = bbmod_surface_check(__surWork1, _width, _height, _format, false);
		__surWork2 = bbmod_surface_check(__surWork2, _width, _height, _format, false);

		surface_set_target(__surWork1);
		shader_set(BBMOD_ShSunShaftMask);
		shader_set_uniform_f(__uLightPos, _screenPos.X * _texelWidth, _screenPos.Y * _texelHeight);
		shader_set_uniform_f(__uAspect, 1.0, _height / _width);
		shader_set_uniform_f(__uMaskRadius, Radius);
		shader_set_uniform_f(__uColor, Color.Red / 255.0, Color.Green / 255.0, Color.Blue / 255.0, Color.Alpha);
		draw_surface_ext(_depth, 0, 0, 0.5, 0.5, 0, c_white, 1.0);
		shader_reset();
		surface_reset_target();

		surface_set_target(__surWork2);
		shader_set(BBMOD_ShRadialBlur);
		shader_set_uniform_f(__uTexel, _texelWidth, _texelHeight);
		shader_set_uniform_f(__uOrigin, _screenPos.X * _texelWidth, _screenPos.Y * _texelHeight);
		shader_set_uniform_f(__uRadius, 0.0);
		shader_set_uniform_f(__uStrength, BlurSize);
		shader_set_uniform_f(__uStep, BlurStep);
		draw_surface(__surWork1, 0, 0);
		shader_reset();
		surface_reset_target();

		surface_set_target(_surfaceDest);
		draw_surface(_surfaceSrc, 0, 0);
		gpu_push_state();
		gpu_set_blendenable(true);
		gpu_set_blendmode(BlendMode);
		shader_set(BBMOD_ShLensDirt);
		texture_set_stage(__uLensDirtTex, PostProcessor.LensDirt);
		var _uvs = texture_get_uvs(PostProcessor.LensDirt);
		shader_set_uniform_f(__uLensDirtUVs, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
		shader_set_uniform_f(__uLensDirtStrength, PostProcessor.LensDirtStrength);
		draw_surface_ext(__surWork2, 0, 0, 2, 2, 0, c_white, 1.0);
		shader_reset();
		gpu_pop_state();
		surface_reset_target();

		return _surfaceDest;
	};

	static destroy = function ()
	{
		if (surface_exists(__surWork1))
		{
			surface_free(__surWork1);
		}
		if (surface_exists(__surWork2))
		{
			surface_free(__surWork2);
		}
		return undefined;
	};
}
