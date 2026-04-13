/// @module D3D11

/// @func bbmod_d3d11_init()
///
/// @desc Initializes BBMOD_D3D11 extension. **Windows only!**
///
/// @return {Bool} Returns `true` if D3D11 is initialized.
function bbmod_d3d11_init()
{
	gml_pragma("forceinline");
	static _initialized = undefined;
	if (_initialized == undefined)
	{
		_initialized = false;
		if (os_type == os_windows && os_browser == browser_not_a_browser)
		{
			try
			{
				var _osInfo = os_get_info();
				var _device = _osInfo[?  "video_d3d11_device"];
				var _context = _osInfo[?  "video_d3d11_context"];
				if (_device != undefined && _context != undefined)
				{
					_initialized = bbmod_d3d11_init_impl(_device, _context);
				}
			}
			catch (_ignore) {}
		}
	}
	return _initialized;
}
