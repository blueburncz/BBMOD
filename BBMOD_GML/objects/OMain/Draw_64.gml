var _windowWidth = window_get_width();
var _windowHeight = window_get_height();
var _x, _y, _text;

// Draw crosshair
if (OPlayer.aiming)
{
	draw_sprite(SprCrosshair, 0,
		round(_windowWidth / 2),
		round(_windowHeight / 2));
}