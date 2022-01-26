x += lengthdir_x(speedCurrent * global.gameSpeed, direction);
y += lengthdir_y(speedCurrent * global.gameSpeed, direction);
z += zspeed * global.gameSpeed;

zspeed -= 0.1 * global.gameSpeed;

var _terrainHeight = OMain.terrain.get_height_xy(x, y);

if (z < _terrainHeight
	&& x >= 0 && x < room_width
	&& y >= 0 && y < room_height)
{
	z = _terrainHeight;
	zspeed = 0;
}