if (true)
{
	var _terrainInfo = new BBMOD_TerrainInfo();
	_terrainInfo.EnableLazyBuild = true;
	_terrainInfo.BuildMesh = false;
	_terrainInfo.TextureRepeat = new BBMOD_Vec2(2.0, 3.0);
	_terrainInfo.Position = new BBMOD_Vec3(1.0, 2.0, 3.0);
	_terrainInfo.Scale = new BBMOD_Vec3(4.0, 5.0, 6.0);
	_terrainInfo.ChunkSize = 16;
	_terrainInfo.ChunkRadius = 2.0;
	_terrainInfo.SmoothHeight = 0;
	var _terrain = new BBMOD_Terrain(_terrainInfo);
	var _layer = new BBMOD_TerrainLayer();
	_layer.BaseOpacity = sprite_get_texture(BBMOD_SprWhite, 0);
	_layer.BaseOpacitySprite = BBMOD_SprWhite;
	_terrain.Layer[0] = _layer;

	var _path = working_directory + "bbmod_terrain_test.bbterr";
	_terrain.to_file(_path);
	var _terrainClone = new BBMOD_Terrain().from_file(_path);
	bbmod_assert(_terrainClone.IsLoaded);
	bbmod_assert(_terrainClone.EnableLazyBuild);
	bbmod_assert(_terrainClone.TextureRepeat.X == 2.0);
	bbmod_assert(_terrainClone.TextureRepeat.Y == 3.0);
	bbmod_assert(_terrainClone.Position.Z == 3.0);
	bbmod_assert(_terrainClone.Scale.Y == 5.0);
	bbmod_assert(_terrainClone.ChunkSize == 16.0);
	bbmod_assert(_terrainClone.ChunkRadius == 2.0);
	bbmod_assert(_terrainClone.Size.X == 1.0);
	bbmod_assert(_terrainClone.Size.Y == 1.0);
	bbmod_assert(_terrainClone.Layer[0] != undefined);
	bbmod_assert(_terrainClone.Layer[0].BaseOpacitySprite == BBMOD_SprWhite);
	var _roundTripPath = working_directory + "bbmod_terrain_roundtrip.bbterr";
	_terrainClone.to_file(_roundTripPath);
	var _originalBuffer = buffer_load(_path);
	var _roundTripBuffer = buffer_load(_roundTripPath);
	bbmod_assert(buffer_get_size(_originalBuffer) == buffer_get_size(_roundTripBuffer));
	buffer_delete(_originalBuffer);
	buffer_delete(_roundTripBuffer);

	var _manager = new BBMOD_ResourceManager();
	var _managedTerrain = _manager.load_sync(_path);
	bbmod_assert(_managedTerrain.IsLoaded);
	_managedTerrain.free();
	_manager.destroy();

	var _invalidPath = working_directory + "bbmod_invalid_terrain.bbterr";
	var _invalidBuffer = buffer_create(1, buffer_grow, 1);
	buffer_write(_invalidBuffer, buffer_string, "INVALID");
	buffer_save(_invalidBuffer, _invalidPath);
	buffer_delete(_invalidBuffer);
	var _invalidFailed = false;
	try
	{
		new BBMOD_Terrain().from_file(_invalidPath);
	}
	catch (_error)
	{
		_invalidFailed = true;
	}
	bbmod_assert(_invalidFailed);

	var _unsupportedPath = working_directory + "bbmod_unsupported_terrain.bbterr";
	var _unsupportedBuffer = buffer_create(1, buffer_grow, 1);
	buffer_write(_unsupportedBuffer, buffer_string, "BBTERR");
	buffer_write(_unsupportedBuffer, buffer_u32, 99);
	buffer_save(_unsupportedBuffer, _unsupportedPath);
	buffer_delete(_unsupportedBuffer);
	var _unsupportedFailed = false;
	try
	{
		new BBMOD_Terrain().from_file(_unsupportedPath);
	}
	catch (_error)
	{
		_unsupportedFailed = true;
	}
	bbmod_assert(_unsupportedFailed);

	var _unknownLayerPath = working_directory + "bbmod_unknown_terrain_layer.bbterr";
	var _unknownLayerBuffer = buffer_create(1, buffer_grow, 1);
	buffer_write(_unknownLayerBuffer, buffer_string, "BBTERR");
	buffer_write(_unknownLayerBuffer, buffer_u32, 1);
	new BBMOD_Vec2().ToBuffer(_unknownLayerBuffer, buffer_f64);
	new BBMOD_Vec3().ToBuffer(_unknownLayerBuffer, buffer_f64);
	new BBMOD_Vec3().ToBuffer(_unknownLayerBuffer, buffer_f64);
	buffer_write(_unknownLayerBuffer, buffer_f64, 128.0);
	buffer_write(_unknownLayerBuffer, buffer_f64, infinity);
	buffer_write(_unknownLayerBuffer, buffer_bool, false);
	buffer_write(_unknownLayerBuffer, buffer_f64, infinity);
	buffer_write(_unknownLayerBuffer, buffer_f64, 1.0);
	buffer_write(_unknownLayerBuffer, buffer_bool, true);
	buffer_write(_unknownLayerBuffer, buffer_bool, false);
	buffer_write(_unknownLayerBuffer, buffer_u8, 0);
	buffer_write(_unknownLayerBuffer, buffer_u8, 0);
	buffer_write(_unknownLayerBuffer, buffer_u32, 1);
	buffer_write(_unknownLayerBuffer, buffer_u32, 1);
	buffer_write(_unknownLayerBuffer, buffer_f64, 0.0);
	buffer_write(_unknownLayerBuffer, buffer_u32, 5);
	buffer_write(_unknownLayerBuffer, buffer_bool, true);
	buffer_write(_unknownLayerBuffer, buffer_string, "BBMOD_UnknownTerrainLayer");
	buffer_save(_unknownLayerBuffer, _unknownLayerPath);
	buffer_delete(_unknownLayerBuffer);
	var _unknownLayerFailed = false;
	try
	{
		new BBMOD_Terrain().from_file(_unknownLayerPath);
	}
	catch (_error)
	{
		_unknownLayerFailed = true;
	}
	bbmod_assert(_unknownLayerFailed);

	_terrainClone.destroy();
	_terrain.destroy();
	file_delete(_path);
	file_delete(_roundTripPath);
	file_delete(_invalidPath);
	file_delete(_unsupportedPath);
	file_delete(_unknownLayerPath);
}
