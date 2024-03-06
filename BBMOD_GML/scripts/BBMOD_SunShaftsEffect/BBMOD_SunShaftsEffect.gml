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
	/// @var {Struct.BBMOD_Vec3}
	LightDirection = _lightDir;

	/// @var {Real}
	Radius = 0.2;

	/// @var {Real}
	Strength = 0.4;

	/// @var {Real}
	BlurSize = 100;

	/// @var {Real}
	BlurStep = 0.01;

	/// @var {Constant.BlendMode}
	BlendMode = bm_add;

	/// @var {Id.Surface}
	/// @private
	__surWork = -1;

	static __uTexel = shader_get_uniform(BBMOD_ShRadialBlur, "u_vTexel");
	static __uOrigin = shader_get_uniform(BBMOD_ShRadialBlur, "u_vOrigin");
	static __uRadius = shader_get_uniform(BBMOD_ShRadialBlur, "u_fRadius");
	static __uStrength = shader_get_uniform(BBMOD_ShRadialBlur, "u_fStrength");
	static __uStep = shader_get_uniform(BBMOD_ShRadialBlur, "u_fStep");

	static __uLightPos = shader_get_uniform(BBMOD_ShSunShaftMask, "u_vLightPos");
	static __uAspect = shader_get_uniform(BBMOD_ShSunShaftMask, "u_vAspect");
	static __uMaskRadius = shader_get_uniform(BBMOD_ShSunShaftMask, "u_fRadius");
	static __uMaskStrength = shader_get_uniform(BBMOD_ShSunShaftMask, "u_fStrength");

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

		var _screenWidth = window_get_width();
		var _screenHeight = window_get_height();
		var _screenPos = _camera.world_to_screen(
			new BBMOD_Vec4(-LightDirection.X, -LightDirection.Y, -LightDirection.Z, 0.0),
			_screenWidth, _screenHeight);

		if (_screenPos == undefined)
		{
			return _surfaceDest;
		}


		var _width = surface_get_width(_surfaceSrc);
		var _height = surface_get_height(_surfaceSrc);
		var _texelWidth = 1.0 / _width;
		var _texelHeight = 1.0 / _height;

		__surWork = bbmod_surface_check(__surWork, _width, _height, surface_rgba8unorm, false);
		surface_set_target(__surWork);
		shader_set(BBMOD_ShSunShaftMask);
		shader_set_uniform_f(__uLightPos, _screenPos.X * _texelWidth, _screenPos.Y * _texelHeight);
		shader_set_uniform_f(__uAspect, 1.0, _height / _width);
		shader_set_uniform_f(__uMaskRadius, Radius);
		shader_set_uniform_f(__uMaskStrength, Strength);
		draw_surface(_depth, 0, 0);
		shader_reset();
		surface_reset_target();

		surface_set_target(_surfaceDest);
		draw_surface(_surfaceSrc, 0, 0);
		gpu_push_state();
		gpu_set_blendenable(true);
		gpu_set_blendmode(BlendMode);
		shader_set(BBMOD_ShRadialBlur);
		shader_set_uniform_f(__uTexel, _texelWidth, _texelHeight);
		shader_set_uniform_f(__uOrigin, _screenPos.X * _texelWidth, _screenPos.Y * _texelHeight);
		shader_set_uniform_f(__uRadius, 0.0);
		shader_set_uniform_f(__uStrength, BlurSize);
		shader_set_uniform_f(__uStep, BlurStep);
		draw_surface(__surWork, 0, 0);
		shader_reset();
		gpu_pop_state();
		surface_reset_target();

		return _surfaceDest;
	};

	static destroy = function ()
	{
		if (surface_exists(__surWork))
		{
			surface_free(__surWork);
		}
		return undefined;
	};
}
