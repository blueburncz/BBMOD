/// @module Core

/// @func bbmod_hdr_is_supported()
///
/// @desc Checks whether high dynamic range (HDR) rendering is supported on
/// the current platform.
///
/// @return {Bool} Returns `true` if HDR rendering is supported on the current
/// platform.
function bbmod_hdr_is_supported()
{
	var _isSupported = surface_format_is_supported(surface_rgba16float);
	return _isSupported;
}

__bbmod_info("HDR is " + (!bbmod_hdr_is_supported() ? "NOT " : "") + "supported!");
