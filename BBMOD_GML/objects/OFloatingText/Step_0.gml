var _terrainHeight = global.terrain.get_height(x, y);

if (_terrainHeight == undefined
	|| z <= _terrainHeight)
{
	instance_destroy();
}