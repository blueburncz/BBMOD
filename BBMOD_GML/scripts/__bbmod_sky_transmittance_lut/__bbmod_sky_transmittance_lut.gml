/// @module Rendering

/// @macro {String} Name of the transmittance LUT sampler uniform used by
/// BBMOD_ShSky_Physical. Pass the texture returned by
/// {@link bbmod_sky_transmittance_lut_get} to this sampler via
/// {@link bbmod_shader_set_global_sampler} each frame before rendering.
///
/// @example
/// ```gml
/// bbmod_shader_set_global_sampler(
///     BBMOD_U_TRANSMITTANCE_LUT,
///     bbmod_sky_transmittance_lut_get());
/// ```
#macro BBMOD_U_TRANSMITTANCE_LUT "bbmod_TransmittanceLUT"

/// @func __bbmod_sky_transmittance_lut_surface()
///
/// @desc Internal. Lazily creates and renders the transmittance LUT surface,
/// re-rendering it if it was lost. Both public functions share this surface.
///
/// @return {Id.Surface}
/// @private
function __bbmod_sky_transmittance_lut_surface()
{
	static _surface  = -1;
	static _rendered = false;

	var _wasValid = surface_exists(_surface);
	_surface = bbmod_surface_check(_surface, 256, 64, surface_rgba16float, false);

	if (!_wasValid || !_rendered)
	{
		_rendered = true;

		// Use a 1x1 dummy surface so draw_surface_stretched produces a
		// full-screen quad with UV [0,1]x[0,1] across the LUT target.
		var _dummy  = surface_create(1, 1);
		var _world  = matrix_get(matrix_world);
		var _camera = camera_create();

		gpu_push_state();
		gpu_set_blendenable(false);
		matrix_set(matrix_world, matrix_build_identity());
		camera_set_view_size(_camera, 256, 64);
		camera_apply(_camera);

		surface_set_target(_surface);
		shader_set(BBMOD_ShTransmittanceLUT);
		draw_surface_stretched(_dummy, 0, 0, 256, 64);
		shader_reset();
		surface_reset_target();

		camera_destroy(_camera);
		matrix_set(matrix_world, _world);
		gpu_pop_state();
		surface_free(_dummy);
	}

	return _surface;
}

/// @func bbmod_sky_transmittance_lut_get()
///
/// @desc Returns the precomputed atmospheric transmittance LUT texture (256x64,
/// rgba16float). The LUT is rendered lazily on first call and re-rendered
/// automatically if the surface is lost (e.g. on device reset).
///
/// UV encoding:
///   U = cos(zenith angle) * 0.5 + 0.5   [-1..1 mapped to 0..1]
///   V = sqrt(altitude / H_atm)           sqrt-mapped for ground-level density
///
/// @return {Pointer.Texture}
function bbmod_sky_transmittance_lut_get()
{
	return surface_get_texture(__bbmod_sky_transmittance_lut_surface());
}

/// @func bbmod_sky_sun_transmittance_color(_sunDirTowardSunZ)
///
/// @desc Returns the atmospheric transmittance color for sunlight at ground
/// level, i.e. the tint applied to the sun's color by the atmosphere. Use this
/// to drive a directional light's color so it matches the physical sky.
///
/// Resolves a single texel from the transmittance LUT into a tiny RGBA8
/// surface and reads it back on the CPU. This causes a GPU pipeline stall,
/// so call it only when the sun direction actually changes.
///
/// @param {Real} _sunDirTowardSunZ The Z component of the normalized direction
///                                  toward the sun (same as bbmod_SunDirection.z
///                                  in the sky shader).
///
/// @return {Struct.BBMOD_Color} Per-channel transmittance as a BBMOD_Color
///                              (RGB 0-255, Alpha 1.0).
function bbmod_sky_sun_transmittance_color(_sunDirTowardSunZ)
{
	static _resolve = -1;

	var _lutSurface = __bbmod_sky_transmittance_lut_surface();

	// LUT U = cosZenith * 0.5 + 0.5, V = sqrt(altitude/H_atm).
	// At ground level altitude=0 so V=0, which maps to the top row (y=0).
	var _px = clamp(round((_sunDirTowardSunZ * 0.5 + 0.5) * 255.0), 0, 255);

	// Resolve that one texel to a 1x1 RGBA8 surface so surface_getpixel works.
	_resolve = bbmod_surface_check(_resolve, 1, 1, surface_rgba8unorm, false);

	var _world  = matrix_get(matrix_world);
	var _camera = camera_create();

	gpu_push_state();
	gpu_set_blendenable(false);
	gpu_set_tex_filter(false);
	matrix_set(matrix_world, matrix_build_identity());
	camera_set_view_size(_camera, 1, 1);
	camera_apply(_camera);

	surface_set_target(_resolve);
	draw_surface_part(_lutSurface, _px, 0, 1, 1, 0, 0);
	surface_reset_target();

	camera_destroy(_camera);
	matrix_set(matrix_world, _world);
	gpu_pop_state();

	var _col = surface_getpixel_ext(_resolve, 0, 0);
	return new BBMOD_Color(
		color_get_red(_col),
		color_get_green(_col),
		color_get_blue(_col),
		1.0);
}
