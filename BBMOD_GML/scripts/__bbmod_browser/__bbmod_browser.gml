/// @module Core

/// @func bbmod_is_browser()
///
/// @desc Checks whether the game is running in a browser.
///
/// @return {Bool} Returns `true` if the game is running in a browser.
function bbmod_is_browser()
{
	gml_pragma("forceinline");
	static _isBrowser = (os_type == os_gxgames || os_browser != browser_not_a_browser);
	return _isBrowser;
}

/// @func bbmod_window_get_width()
///
/// @desc Retrieves the width of the game window.
///
/// @return {Real} The window width.
///
/// @note Useful for GX.games platform, where `window_get_width()` doesn't give
/// the value needed.
function bbmod_window_get_width()
{
	gml_pragma("forceinline");
	if (bbmod_is_browser())
	{
		var _position = application_get_position();
		return max(_position[2] - _position[0], 1);
	}
	return max(window_get_width(), 1);
}

/// @func bbmod_window_get_height()
///
/// @desc Retrieves the width of the game window.
///
/// @return {Real} The window height.
///
/// @note Useful for GX.games platform, where `window_get_height()` doesn't give
/// the value needed.
function bbmod_window_get_height()
{
	gml_pragma("forceinline");
	if (bbmod_is_browser())
	{
		var _position = application_get_position();
		return max(_position[3] - _position[1], 1);
	}
	return max(window_get_height(), 1);
}
