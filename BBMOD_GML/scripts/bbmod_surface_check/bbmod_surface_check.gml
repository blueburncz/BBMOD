/// @func bbmod_surface_check(_surface, _width, _height)
/// @desc Checks whether the surface exists and if it has correct size. Broken
/// surfaces are recreated. Surfaces of wrong size are resized.
/// @param {surface} _surface The surface to check.
/// @param {real} _width The desired width of the surface.
/// @param {real} _height The desired height of the surface.
/// @return {surface} The surface.
function bbmod_surface_check(_surface, _width, _height)
{
	_width = max(round(_width), 1);
	_height = max(round(_height), 1);

	if (!surface_exists(_surface))
	{
		return surface_create(_width, _height);
	}

	if (surface_get_width(_surface) != _width
		|| surface_get_height(_surface) != _height)
	{
		surface_resize(_surface, _width, _height);
	}

	return _surface;
}