var _windowWidth = window_get_width();
var _windowHeight = window_get_height();

var _cam = OPlayer.camera;
var _viewProjMat = matrix_multiply(_cam.get_view_mat(), _cam.get_proj_mat());

// Draw zombie healthbar
with (OZombie)
{
	if (hp <= 0 || hp == hpMax)
	{
		// Do not draw healthbar when dead or HP is full.
		continue;
	}
	var _screenPos = world_to_screen(
		new BBMOD_Vec3(x, y, z + 42), _viewProjMat, _windowWidth, _windowHeight);
	if (!_screenPos)
	{
		// Zombie is outside of the screen.
		continue;
	}
	var _width = 60;
	var _height = 10;
	var _x = round(_screenPos.X - _width * 0.5);
	var _y = round(_screenPos.Y - _height * 0.5);
	draw_rectangle_color(_x, _y, _x + _width, _y + _height, 0, 0, 0, 0, false);
	draw_rectangle_color(_x + 2, _y + 2, _x + 2 + (_width - 4) * (hp / hpMax), _y + 2 + _height - 4, c_red, c_red, c_red, c_red, false);
}

// Draw floating text
var _font = draw_get_font();
draw_set_font(FntFloatingText);
with (OFloatingText)
{
	var _screenPos = world_to_screen(
		new BBMOD_Vec3(x, y, z), _viewProjMat, _windowWidth, _windowHeight);
	if (!_screenPos)
	{
		// Floating text is outside of the screen.
		continue;
	}
	draw_text_color(_screenPos.X + 2, _screenPos.Y + 2, text, 0, 0, 0, 0, 1);
	draw_text(_screenPos.X, _screenPos.Y, text);
}
draw_set_font(_font);

// Draw crosshair
if (OPlayer.aiming)
{
	draw_sprite(SprCrosshair, 0,
		round(_windowWidth / 2),
		round(_windowHeight / 2));
}