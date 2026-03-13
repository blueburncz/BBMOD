renderer.present();

// Debug: cloud shadow texture preview (bottom-left corner).
if (surface_exists(clouds.__shadowSurf))
{
	var _size = 256;
	var _x = 8;
	var _y = display_get_gui_height() - _size - 8;
	draw_surface_stretched(clouds.__shadowSurf, _x, _y, _size, _size);
}
