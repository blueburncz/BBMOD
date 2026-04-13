/// @module VTF

/// @func bbmod_texture_set_stage_vs(_slot, _texture)
///
/// @desc Passes a texture to a vertex shader. On Windows this uses
/// BBMOD_D3D11 (if available), otherwise GameMaker's built-in
/// `texture_set_stage` is used, which should work on OpenGL-based platforms.
///
/// @param {Real} _slot The vertex texture slot index. Must be in range 0..7.
/// @param {Pointer.Texture} _texture The texture to pass.
///
/// @note You can test if this function is supported with
/// {@link bbmod_vtf_is_supported}.
///
/// @see bbmod_vtf_is_supported
function bbmod_texture_set_stage_vs(_slot, _texture)
{
	gml_pragma("forceinline");

	if (os_type == os_windows && os_browser == browser_not_a_browser)
	{
		try
		{
			if (bbmod_d3d11_init())
			{
				texture_set_stage(0, _texture);
				bbmod_d3d11_copy_srv_ps_vs(0, _slot);
			}
		}
		catch (_ignore) {}

		// Note: On Windows this wouldn't work anyways, so we can simply return...
		return;
	}

	texture_set_stage(_slot, _texture);
}

/// @func bbmod_vtf_is_supported()
///
/// @desc Checks whether vertex texture fetching is supported on the current
/// platform.
///
/// @return {Bool} Returns `true` if vertex texture fetching is supported on
/// the current platform.
function bbmod_vtf_is_supported()
{
	var _isSupported = undefined;

	if (_isSupported == undefined)
	{
		var _shader = BBMOD_ShCheckVTF;

		if (shader_is_compiled(_shader))
		{
			var _surface = bbmod_surface_check(-1, 1, 1, surface_rgba8unorm, false);
			surface_set_target(_surface);
			draw_clear(c_black);
			shader_set(_shader);
			bbmod_texture_set_stage_vs(
				shader_get_sampler_index(_shader, "u_texTest"),
				sprite_get_texture(BBMOD_SprWhite, 0));
			draw_sprite(BBMOD_SprWhite, 0, 0, 0);
			shader_reset();
			surface_reset_target();

			var _pixel = surface_getpixel_ext(_surface, 0, 0);
			_isSupported = (_pixel == $FFFFFFFF);

			surface_free(_surface);
		}
		else
		{
			_isSupported = false;
		}
	}

	return _isSupported;
}

__bbmod_info("VTF is " + (!bbmod_vtf_is_supported() ? "NOT " : "") + "supported!");
