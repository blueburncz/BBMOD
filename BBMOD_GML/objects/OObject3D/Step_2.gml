z += zspeed;
zspeed -= 0.1;

var _terrainHeight = OMain.terrain.get_height_xy(x, y);

if (z < _terrainHeight)
{
	z = _terrainHeight;
	zspeed = 0;
}