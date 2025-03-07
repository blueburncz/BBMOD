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
