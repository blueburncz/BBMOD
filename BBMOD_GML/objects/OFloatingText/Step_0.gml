var _terrainHeight = OMain.terrain.get_height(x, y);

if (_terrainHeight == undefined
	|| z <= _terrainHeight)
{
	instance_destroy();
}