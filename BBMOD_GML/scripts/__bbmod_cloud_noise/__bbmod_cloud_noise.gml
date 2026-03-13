/// @module Rendering

////////////////////////////////////////////////////////////////////////////////
//
// Macros
//

/// @macro {String} Sampler name for the 1024x1024 base cloud noise atlas.
/// R=FBM4, G=invWorley1, B=invWorley2, A=invWorley3.
#macro BBMOD_U_CLOUD_NOISE_BASE   "bbmod_CloudNoiseBase"

/// @macro {String} Sampler name for the 256x128 cloud detail noise atlas.
/// R=FBM2 (erosion), G=cVNoise (shimmer).
#macro BBMOD_U_CLOUD_NOISE_DETAIL "bbmod_CloudNoiseDetail"

////////////////////////////////////////////////////////////////////////////////
//
// Internal helpers
//

/// @func __bbmod_cloud_noise_bake_impl(_shader, _w, _h)
/// @private
function __bbmod_cloud_noise_bake_impl(_shader, _w, _h)
{
	var _surf  = surface_create(_w, _h, surface_rgba8unorm);
	var _dummy = surface_create(1, 1);
	var _world  = matrix_get(matrix_world);
	var _camera = camera_create();

	gpu_push_state();
	gpu_set_blendenable(false);
	matrix_set(matrix_world, matrix_build_identity());
	camera_set_view_size(_camera, _w, _h);
	camera_apply(_camera);

	surface_set_target(_surf);
	shader_set(_shader);
	draw_surface_stretched(_dummy, 0, 0, _w, _h);
	shader_reset();
	surface_reset_target();

	camera_destroy(_camera);
	matrix_set(matrix_world, _world);
	gpu_pop_state();
	surface_free(_dummy);

	return _surf;
}

////////////////////////////////////////////////////////////////////////////////
//
// Public API
//

/// @func bbmod_cloud_noise_base_get()
///
/// @desc Returns the texture of the 1024x1024 base cloud noise atlas
/// (128x128 x 64 Z-slices). Bakes it on the first call.
/// Channels: R=FBM4, G=invWorley(1x), B=invWorley(2.1x), A=invWorley(4.3x).
///
/// @return {Pointer.Texture}
function bbmod_cloud_noise_base_get()
{
	static _surface  = -1;
	static _rendered = false;

	var _wasValid = surface_exists(_surface);

	if (!_wasValid)
	{
		// Re-bake if the surface was lost (e.g. focus regain on mobile/web).
		_rendered = false;
	}

	if (!_rendered)
	{
		if (_wasValid) surface_free(_surface);
		_surface  = __bbmod_cloud_noise_bake_impl(BBMOD_ShCloudNoiseBake, 1024, 1024);
		_rendered = true;
	}

	return surface_get_texture(_surface);
}

/// @func bbmod_cloud_noise_detail_get()
///
/// @desc Returns the texture of the 256x128 cloud detail noise atlas
/// (32x32 x 32 Z-slices). Bakes it on the first call.
/// Channels: R=FBM2, G=cVNoise.
///
/// @return {Pointer.Texture}
function bbmod_cloud_noise_detail_get()
{
	static _surface  = -1;
	static _rendered = false;

	var _wasValid = surface_exists(_surface);

	if (!_wasValid)
	{
		_rendered = false;
	}

	if (!_rendered)
	{
		if (_wasValid) surface_free(_surface);
		_surface  = __bbmod_cloud_noise_bake_impl(BBMOD_ShCloudNoiseDetailBake, 256, 128);
		_rendered = true;
	}

	return surface_get_texture(_surface);
}
