x += lengthdir_x(speedCurrent * global.gameSpeed, direction);
y += lengthdir_y(speedCurrent * global.gameSpeed, direction);
z += zspeed * global.gameSpeed;

zspeed -= 0.1 * global.gameSpeed;

var _terrainHeight = global.terrain.get_height(x, y);

if (_terrainHeight != undefined
	&& z < _terrainHeight)
{
	z = _terrainHeight;
	zspeed = 0;
}
