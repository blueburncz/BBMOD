var _map = global.__bbmodSpriteCallback;
var _id = async_load[? "id"];
var _data = _map[? _id];

if (async_load[? "status"] == false)
{
	_data.Callback(new BBMOD_Exception("Async load failed!"));
}
else
{
	_data.Callback(undefined, _id);
}

ds_map_delete(_map, _id);