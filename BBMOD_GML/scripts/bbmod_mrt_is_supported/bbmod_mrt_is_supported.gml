/// @module Core

/// @func bbmod_mrt_is_supported()
///
/// @desc Checks whether multiple render targets are supported on the current
/// platform.
///
/// @return {Bool} Returns `true` if multiple render targets are supported on
/// the current platform.
function bbmod_mrt_is_supported()
{
	var _isSupported = undefined;

	if (_isSupported == undefined)
	{
		var _shader = __BBMOD_ShCheckMRT;

		if (shader_is_compiled(_shader))
		{
			var _surface1 = bbmod_surface_check(-1, 1, 1, surface_rgba8unorm, false);
			var _surface2 = bbmod_surface_check(-1, 1, 1, surface_rgba8unorm, false);
			surface_set_target_ext(0, _surface1);
			surface_set_target_ext(1, _surface2);
			draw_clear(c_black);
			shader_set(_shader);
			draw_sprite(BBMOD_SprWhite, 0, 0, 0);
			shader_reset();
			surface_reset_target();

			var _pixel1 = surface_getpixel_ext(_surface1, 0, 0);
			var _pixel2 = surface_getpixel_ext(_surface2, 0, 0);
			_isSupported = (_pixel1 == $FFFFFFFF && _pixel2 == $FFFFFFFF);

			surface_free(_surface1);
			surface_free(_surface2);
		}
		else
		{
			_isSupported = false;
		}
	}

	return _isSupported;
}

__bbmod_info("MRT " + (!bbmod_mrt_is_supported() ? "not " : "") + "supported!");
