var _windowWidth = window_get_width();
var _windowHeight = window_get_height();
var _font = draw_get_font();

var _cam = OPlayer.camera;
var _viewProjMat = matrix_multiply(_cam.get_view_mat(), _cam.get_proj_mat());

// Draw zombies' healthbar
with (OZombie)
{
	if (hp <= 0 || hp == hpMax)
	{
		// Do not draw healthbar when dead or HP is full.
		continue;
	}
	var _screenPos = WorldToScreen(
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
	draw_rectangle_color(_x + 2, _y + 2, _x + 2 + (_width - 4) * (hp / hpMax), _y + 2 + _height - 4,
		c_red, c_red, c_maroon, c_maroon, false);
}

draw_set_font(Fnt16);

// Draw floating text
with (OFloatingText)
{
	var _screenPos = WorldToScreen(
		new BBMOD_Vec3(x, y, z), _viewProjMat, _windowWidth, _windowHeight);
	if (!_screenPos)
	{
		// Floating text is outside of the screen.
		continue;
	}
	DrawTextShadow(_screenPos.X, _screenPos.Y, text);
}

// Draw item pickup text
with (OGun)
{
	if (OPlayer.pickupTarget == id)
	{
		continue;
	}
	if (point_distance(x, y, OPlayer.x, OPlayer.y) > pickupRange)
	{
		continue;
	}
	var _screenPos = WorldToScreen(
		new BBMOD_Vec3(x, y, z), _viewProjMat, _windowWidth, _windowHeight);
	if (!_screenPos)
	{
		// Text is outside of the screen.
		continue;
	}
	DrawTextShadow(_screenPos.X, _screenPos.Y, "E");
}

draw_set_font(_font);

// Draw crosshair
if (OPlayer.aiming)
{
	draw_sprite(SprCrosshair, 0,
		round(_windowWidth / 2),
		round(_windowHeight / 2));
}

// Draw score
draw_set_font(Fnt24);
draw_set_halign(fa_center);
var _text = string(score);
if (global.scoreBonus > 0)
{
	_text += "+" + string(global.scoreBonus);
}
DrawTextShadow(floor(_windowWidth * 0.5), 16, _text);

// Draw time remaining till the next wave is spawned
draw_set_font(Fnt16);
draw_set_halign(fa_right);
DrawTextShadow(_windowWidth - 16, 16, string(ceil(waveTimeout)) + "s", (waveTimeout > 5.0) ? c_white : c_red);

// Draw ammo
if (OPlayer.ammo > 0)
{
	draw_set_valign(fa_bottom);
	DrawTextShadow(_windowWidth - 16, _windowHeight - 16, OPlayer.ammo);
	draw_set_valign(fa_top);
}

// Draw pause text
if (global.gameSpeed == 0)
{
	draw_set_font(Fnt48);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	DrawTextShadow(round(_windowWidth * 0.5), _windowHeight - 16, "PAUSE");
	draw_set_valign(fa_top);
}

draw_set_halign(fa_left);
draw_set_font(_font);