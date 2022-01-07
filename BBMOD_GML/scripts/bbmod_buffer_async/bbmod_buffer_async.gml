/// @var {ds_map<real, function>}
/// @private
global.__bbmodBufferLoadAsyncCallback = ds_map_create();

/// @func bbmod_buffer_load_async(_file, _callback)
/// @desc
/// @param {string} _file
/// @param {function} _callback
function bbmod_buffer_load_async(_file, _callback)
{
	var _buffer = buffer_create(1, buffer_grow, 1);
	var _id = buffer_load_async(_buffer, _file, 0, -1);
	global.__bbmodBufferLoadAsyncCallback[? _id] = {
		//File: _file,
		Buffer: _buffer,
		Callback: _callback,
	};
}

/// @func bbmod_buffer_load_async_update(_asyncLoad)
/// @desc
/// @param {ds_map} _asyncLoad
function bbmod_buffer_load_async_update(_asyncLoad)
{
	var _map = global.__bbmodBufferLoadAsyncCallback;
	var _id = _asyncLoad[? "id"];
	var _data = _map[? _id];

	if (_asyncLoad[? "status"] == false)
	{
		buffer_delete(_data.Buffer);
		_data.Callback(new BBMOD_Exception("Async load failed!"));
	}
	else
	{
		var _buffer = _data.Buffer;
		buffer_seek(_buffer, buffer_seek_start, 0);
		_data.Callback(undefined, _buffer);
	}

	ds_map_delete(_map, _id);
}