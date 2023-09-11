/// @module Core

/// @func bbmod_surface_check(_surface, _width, _height[, _format[, _depthBuffer]])
///
/// @desc Assures a surface has the correct size and format. Reallocates the surface
/// if it does not exist.
///
/// @param {Id.Surface} _surface The surface to check.
/// @param {Real} _width The desired width of the surface.
/// @param {Real} _height The desired height of the surface.
/// @param {Constant.SurfaceFormatType} [_format] The surface format to use when
/// the surface is created. Use one of the `surface_` constants. Defaults to 
/// `surface_rgba8unorm`.
/// @param {Bool} [_depthBuffer] Whether to create a depth buffer for the surface.
/// Defaults to `true`.
///
/// @return {Id.Surface} The surface.
function bbmod_surface_check(_surface, _width, _height, _format=surface_rgba8unorm, _depthBuffer=true)
{
	_width = max(round(_width), 1);
	_height = max(round(_height), 1);

	if (!surface_exists(_surface)
		|| surface_get_format(_surface) != _format)
	{
		var _depthDisabled = surface_get_depth_disable();
		surface_depth_disable(!_depthBuffer);
		if (surface_exists(_surface))
		{
			surface_free(_surface);
		}
		_surface = surface_create(_width, _height, _format);
		surface_depth_disable(_depthDisabled);
	}
	else if (surface_get_width(_surface) != _width
		|| surface_get_height(_surface) != _height)
	{
		var _depthDisabled = surface_get_depth_disable();
		surface_depth_disable(!_depthBuffer);
		surface_resize(_surface, _width, _height);
		surface_depth_disable(_depthDisabled);
	}

	return _surface;
}
