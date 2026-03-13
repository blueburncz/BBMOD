/// @module Rendering

////////////////////////////////////////////////////////////////////////////////
//
// BBMOD_CloudRenderer
//

/// @func BBMOD_CloudRenderer()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Manages 2D layered cloud rendering for the physical sky shader.
/// Supports 1-3 independently moving cloud layers. Each layer samples a
/// tileable 2D noise texture (or procedural FBM) at a horizontal plane and
/// applies per-layer coverage, density, and wind.
///
/// @example
/// ```gml
/// /// @desc Create event
/// clouds = new BBMOD_CloudRenderer();
/// clouds.Sun = sunLight;
/// clouds.set_weather(BBMOD_ECloudWeather.PartlyCloudy);
///
/// /// @desc Step event
/// clouds.update(delta_time, camera.Position.X, camera.Position.Y,
///     camera.Position.Z);
///
/// /// @desc Draw event (before renderer.render())
/// clouds.render_shadow(camera.Position.X, camera.Position.Y);
/// ```
///
/// @see BBMOD_ECloudWeather
function BBMOD_CloudRenderer(): BBMOD_IDestructible() constructor
{
	////////////////////////////////////////////////////////////////////////////////
	// Public properties

	/// @var {Struct.BBMOD_DirectionalLight} The scene directional light (sun/moon).
	/// Must be assigned before calling {@link BBMOD_CloudRenderer.update}.
	Sun = undefined;

	/// @var {Real} World Z of the bottom of the first cloud layer. Defaults to 1200.
	Altitude = 1200;

	/// @var {Real} Vertical separation between layers (world units). Defaults to 400.
	LayerSep = 400;

	/// @var {Real} Number of active cloud layers: 1, 2, or 3. Defaults to 1.
	LayerCount = 1;

	/// @var {Real} Approximate cloud feature size in world units (layer 0).
	/// Larger = bigger individual clouds. Defaults to 8000.
	CloudSize = 8000;

	/// @var {Real} Cloud feature size for layer 1. Defaults to 12000.
	CloudSize1 = 12000;

	/// @var {Real} Cloud feature size for layer 2. Defaults to 5000.
	CloudSize2 = 5000;

	/// @var {Real} Sky coverage for layer 0 [0, 1]. 0 = clear, 1 = overcast.
	/// Defaults to 0.3.
	Coverage = 0.3;

	/// @var {Real} Sky coverage for layer 1 [0, 1]. Defaults to 0.
	Coverage1 = 0.0;

	/// @var {Real} Sky coverage for layer 2 [0, 1]. Defaults to 0.
	Coverage2 = 0.0;

	/// @var {Real} Opacity of layer 0 at full coverage [0, 1]. Defaults to 0.8.
	Density = 0.8;

	/// @var {Real} Opacity of layer 1 at full coverage [0, 1]. Defaults to 0.7.
	Density1 = 0.7;

	/// @var {Real} Opacity of layer 2 at full coverage [0, 1]. Defaults to 0.6.
	Density2 = 0.6;

	/// @var {Real} Aerial perspective fade coefficient. Controls how quickly
	/// clouds fade into the atmosphere near the horizon.
	/// Larger = more aggressive fade. Typical range: 0.00001 -- 0.0001.
	/// Defaults to 0.00003.
	HorizonFade = 0.00003;

	/// @var {Struct.BBMOD_Vec2} Global XY offset applied to all cloud layers on
	/// top of their individual wind offsets. Useful for manually repositioning
	/// clouds. Defaults to (0, 0).
	Offset = new BBMOD_Vec2(0.0, 0.0);

	/// @var {Struct.BBMOD_Vec2} Normalized horizontal wind direction. Defaults to (1, 0).
	WindDirection = new BBMOD_Vec2(1.0, 0.0);

	/// @var {Real} Wind speed in world units per second. Defaults to 8.
	WindSpeed = 8.0;

	/// @var {Struct.BBMOD_Vec2} Accumulated wind displacement, advanced by
	/// {@link BBMOD_CloudRenderer.update}. Read-only in normal use.
	WindOffset = new BBMOD_Vec2(0.0, 0.0);

	/// @var {Pointer.Texture, Undefined} Optional tileable 2D noise texture.
	/// Assign a texture pointer from any seamlessly-tileable noise sprite.
	/// When `undefined`, procedural FBM hash noise is used instead.
	/// Defaults to `undefined`.
	NoiseTexture = undefined;

	/// @var {Pointer.Texture, Undefined} Optional artist-painted coverage mask.
	/// Bright pixels = more cloud, dark = less cloud. Applied to all layers.
	/// When `undefined`, the coverage mask is disabled. Defaults to `undefined`.
	CoverageMap = undefined;

	/// @var {Real} World-space extent of the coverage map. The map is centred at
	/// world origin. `CoverageMapScale = 1.0 / half_extent_in_world_units`.
	/// Defaults to 1.0 / 10000.
	CoverageMapScale = 1.0 / 10000.0;

	////////////////////////////////////////////////////////////////////////////////
	// Private

	/// @var {Struct.BBMOD_Vec2}
	/// @private
	__windOffset1 = new BBMOD_Vec2(0.0, 0.0);

	/// @var {Struct.BBMOD_Vec2}
	/// @private
	__windOffset2 = new BBMOD_Vec2(0.0, 0.0);

	/// @var {Id.Surface}
	/// @private
	__shadowSurf = -1;

	/// @var {Id.Surface}
	/// @private
	__dummySurf = -1;

	/// @var {Real}
	/// @private
	__shadowSize = 4000.0;

	/// @var {Real}
	/// @private
	__shadowRes = 512;

	/// @var {Real}
	/// @private
	__shadowSnapX = 0.0;

	/// @var {Real}
	/// @private
	__shadowSnapY = 0.0;

	////////////////////////////////////////////////////////////////////////////////

	/// @func set_weather(_type)
	///
	/// @desc Configures cloud properties to match a weather state.
	/// The primary way to set up clouds -- override individual properties
	/// afterwards for fine-tuning.
	///
	/// @param {Real} _type The weather preset. Use values from
	/// {@link BBMOD_ECloudWeather}.
	///
	/// @return {Struct.BBMOD_CloudRenderer} Returns `self`.
	static set_weather = function(_type)
	{
		switch (_type)
		{
		case BBMOD_ECloudWeather.Clear:
			LayerCount = 1;
			CloudSize = 3000;
			Coverage = 0.12;
			Density = 0.80;
			WindSpeed = 5.0;
			break;

		case BBMOD_ECloudWeather.PartlyCloudy:
			LayerCount = 2;
			CloudSize = 8000;
			CloudSize1 = 14000;
			Coverage = 0.45;
			Coverage1 = 0.28;
			Density = 0.90;
			Density1 = 0.70;
			WindSpeed = 8.0;
			break;

		case BBMOD_ECloudWeather.Cloudy:
			LayerCount = 2;
			CloudSize = 10000;
			CloudSize1 = 7000;
			Coverage = 0.60;
			Coverage1 = 0.40;
			Density = 0.93;
			Density1 = 0.78;
			WindSpeed = 13.0;
			break;

		case BBMOD_ECloudWeather.Overcast:
			LayerCount = 3;
			CloudSize = 13000;
			CloudSize1 = 8000;
			CloudSize2 = 5000;
			Coverage = 0.72;
			Coverage1 = 0.58;
			Coverage2 = 0.42;
			Density = 0.96;
			Density1 = 0.88;
			Density2 = 0.72;
			WindSpeed = 18.0;
			break;

		case BBMOD_ECloudWeather.Stormy:
			LayerCount = 3;
			CloudSize = 11000;
			CloudSize1 = 7000;
			CloudSize2 = 4000;
			Coverage = 0.84;
			Coverage1 = 0.72;
			Coverage2 = 0.58;
			Density = 1.0;
			Density1 = 0.95;
			Density2 = 0.85;
			WindSpeed = 28.0;
			break;
		}

		return self;
	};

	/// @func update(_deltaTime, _x, _y, _z)
	///
	/// @desc Advances wind animation and pushes all cloud uniforms to the sky
	/// shader. Call once per step event.
	///
	/// @param {Real} _deltaTime delta_time in microseconds.
	/// @param {Real} _x Camera world X.
	/// @param {Real} _y Camera world Y.
	/// @param {Real} _z Camera world Z.
	///
	/// @return {Struct.BBMOD_CloudRenderer} Returns `self`.
	static update = function(_deltaTime, _x, _y, _z)
	{
		var _dt = _deltaTime * 0.000001;

		// Advance per-layer wind offsets. Layers drift at different speeds for
		// a natural parallax effect.
		var _wx = WindDirection.X * WindSpeed * _dt;
		var _wy = WindDirection.Y * WindSpeed * _dt;

		WindOffset.X += _wx;
		WindOffset.Y += _wy;
		__windOffset1.X += _wx * 0.65;
		__windOffset1.Y += _wy * 0.65;
		__windOffset2.X += _wx * 1.35;
		__windOffset2.Y += _wy * 1.35;

		var _useTexture = (NoiseTexture != undefined) ? 1.0 : 0.0;

		bbmod_shader_set_global_f3("bbmod_CloudCamPos", _x, _y, _z);
		bbmod_shader_set_global_f("bbmod_CloudAltitude", Altitude);
		bbmod_shader_set_global_f("bbmod_CloudLayerSep", LayerSep);
		bbmod_shader_set_global_f("bbmod_CloudLayerCount", LayerCount);
		bbmod_shader_set_global_f("bbmod_CloudUseNoiseTexture", _useTexture);

		// Per-layer uniforms
		bbmod_shader_set_global_f2("bbmod_CloudWindOffset0", WindOffset.X + Offset.X, WindOffset.Y + Offset.Y);
		bbmod_shader_set_global_f2("bbmod_CloudWindOffset1", __windOffset1.X + Offset.X, __windOffset1.Y + Offset.Y);
		bbmod_shader_set_global_f2("bbmod_CloudWindOffset2", __windOffset2.X + Offset.X, __windOffset2.Y + Offset.Y);
		bbmod_shader_set_global_f("bbmod_CloudScale0", 1.0 / CloudSize);
		bbmod_shader_set_global_f("bbmod_CloudScale1", 1.0 / CloudSize1);
		bbmod_shader_set_global_f("bbmod_CloudScale2", 1.0 / CloudSize2);
		bbmod_shader_set_global_f("bbmod_CloudCoverage0", Coverage);
		bbmod_shader_set_global_f("bbmod_CloudCoverage1", Coverage1);
		bbmod_shader_set_global_f("bbmod_CloudCoverage2", Coverage2);
		bbmod_shader_set_global_f("bbmod_CloudDensity0", Density);
		bbmod_shader_set_global_f("bbmod_CloudDensity1", Density1);
		bbmod_shader_set_global_f("bbmod_CloudDensity2", Density2);
		bbmod_shader_set_global_f("bbmod_CloudHorizonFade", HorizonFade);

		// Noise texture (optional)
		if (NoiseTexture != undefined)
		{
			bbmod_shader_set_global_sampler("bbmod_CloudNoise", NoiseTexture);
		}

		// Coverage map (optional)
		var _coverageMapEnable = (CoverageMap != undefined) ? 1.0 : 0.0;
		bbmod_shader_set_global_f("bbmod_CloudCoverageMapEnable", _coverageMapEnable);
		if (CoverageMap != undefined)
		{
			bbmod_shader_set_global_sampler("bbmod_CloudCoverageMap", CoverageMap);
			bbmod_shader_set_global_f("bbmod_CloudCoverageMapScale", CoverageMapScale);
		}

		return self;
	};

	/// @func render_shadow(_camX, _camY[, _camZ])
	///
	/// @desc Renders the cloud shadow map and sets the global shadow uniforms
	/// used by the forward/deferred lighting shaders. Call once per frame in
	/// the Draw event BEFORE `renderer.render()`.
	///
	/// @param {Real} _camX Camera world X.
	/// @param {Real} _camY Camera world Y.
	/// @param {Real} [_camZ] Camera world Z. Defaults to 0.
	///
	/// @return {Struct.BBMOD_CloudRenderer} Returns `self`.
	static render_shadow = function(_camX, _camY, _camZ = 0)
	{
		if (Sun == undefined)
		{
			return self;
		}

		var _res = __shadowRes;
		var _texelSz = __shadowSize / _res;
		__shadowSnapX = floor(_camX / _texelSz) * _texelSz;
		__shadowSnapY = floor(_camY / _texelSz) * _texelSz;

		__shadowSurf = bbmod_surface_check(__shadowSurf, _res, _res, surface_rgba8unorm, false);
		if (!surface_exists(__dummySurf))
		{
			__dummySurf = surface_create(1, 1);
		}

		var _mw = matrix_get(matrix_world);
		var _mv = matrix_get(matrix_view);
		var _mp = matrix_get(matrix_projection);

		matrix_set(matrix_world, matrix_build_identity());
		matrix_set(matrix_view, matrix_build_identity());
		matrix_set(matrix_projection, matrix_build_projection_ortho(_res, _res, -1, 1));

		surface_set_target(__shadowSurf);
		draw_clear(c_white);
		gpu_set_blendmode(bm_normal);

		var _sh = BBMOD_ShCloudShadow;
		shader_set(_sh);
		shader_set_uniform_f(shader_get_uniform(_sh, "bbmod_CloudShadowPos"), __shadowSnapX, __shadowSnapY, 0.0);
		shader_set_uniform_f(shader_get_uniform(_sh, "bbmod_CloudShadowSize"), __shadowSize);
		shader_set_uniform_f(shader_get_uniform(_sh, "bbmod_CloudCamPos"), _camX, _camY, _camZ);
		shader_set_uniform_f(shader_get_uniform(_sh, "bbmod_SunDirection"), -Sun.Direction.X, -Sun.Direction.Y, -Sun.Direction.Z);
		shader_set_uniform_f(shader_get_uniform(_sh, "bbmod_CloudAltitude"), Altitude);
		shader_set_uniform_f(shader_get_uniform(_sh, "bbmod_CloudCoverage"), Coverage);
		shader_set_uniform_f(shader_get_uniform(_sh, "bbmod_CloudDensity"), Density);
		shader_set_uniform_f(shader_get_uniform(_sh, "bbmod_CloudScale"), 1.0 / CloudSize);
		shader_set_uniform_f(shader_get_uniform(_sh, "bbmod_CloudWindOffset"), WindOffset.X + Offset.X, WindOffset.Y + Offset.Y);
		shader_set_uniform_f(shader_get_uniform(_sh, "bbmod_CloudUseNoiseTexture"), (NoiseTexture != undefined) ? 1.0 : 0.0);
		if (NoiseTexture != undefined)
		{
			texture_set_stage(shader_get_sampler_index(_sh, "bbmod_CloudNoise"), NoiseTexture);
		}

		draw_surface_stretched(__dummySurf, 0, 0, _res, _res);
		shader_reset();
		surface_reset_target();

		// Set position/size globals so scene shaders can compute cloud-shadow UV.
		// The actual shadowmap texture is set by the renderer after blitting the
		// cloud shadow into the geometry shadowmap's alpha channel.
		bbmod_shader_set_global_f2("bbmod_CloudShadowPos", __shadowSnapX, __shadowSnapY);
		bbmod_shader_set_global_f("bbmod_CloudShadowSize", __shadowSize);

		matrix_set(matrix_world, _mw);
		matrix_set(matrix_view, _mv);
		matrix_set(matrix_projection, _mp);

		return self;
	};

	/// @func destroy()
	///
	/// @desc Frees surfaces used by the cloud renderer.
	///
	/// @return {Undefined} Returns `undefined`.
	static destroy = function()
	{
		if (surface_exists(__shadowSurf))
		{
			surface_free(__shadowSurf);
		}
		if (surface_exists(__dummySurf))
		{
			surface_free(__dummySurf);
		}
		return undefined;
	};
}

////////////////////////////////////////////////////////////////////////////////
//
// Enums
//

/// @enum Weather presets for {@link BBMOD_CloudRenderer.set_weather}.
enum BBMOD_ECloudWeather
{
	/// @member A few wisps, ~5% sky coverage.
	Clear,
	/// @member Scattered cumulus with clear gaps, ~30% coverage.
	PartlyCloudy,
	/// @member Good cover, sun still visible, ~55% coverage.
	Cloudy,
	/// @member Near-continuous ceiling, ~75% coverage.
	Overcast,
	/// @member Solid dark ceiling, ~90% coverage.
	Stormy,
};
