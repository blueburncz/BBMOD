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
		var _shader = BBMOD_ShCheckMRT;

		if (shader_is_compiled(_shader))
		{
			var _surface1 = surface_create(1, 1);
			var _surface2 = surface_create(1, 1);
			surface_set_target_ext(0, _surface1);
			_isSupported = surface_set_target_ext(1, _surface2);
			surface_reset_target();
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

__bbmod_info("MRT is " + (!bbmod_mrt_is_supported() ? "NOT " : "") + "supported!");
