/// @var {ds_map<real, function>}
/// @private
global.__bbmodAsyncCallback = ds_map_create();

/// @var {ds_map<real, function>}
/// @private
global.__bbmodSpriteCallback = ds_map_create();

/// @func bbmod_buffer_load_async(_file, _callback)
/// @desc Asynchronnously loads a buffer from a file.
/// @param {string} _file The path to the file to load the buffer from.
/// @param {function} _callback The function to execute when the buffer is
/// loaded or if an error occurs. It must take the error as the first argument
/// and the buffer as the second argument. If no error occurs, then `undefined`
/// is passed. If an error does occur, then buffer is `undefined`.
/// @example
/// ```gml
/// bbmod_buffer_load_async("save.bin", function (_error, _buffer) {
///     if (_error != undefined)
///     {
///         // Handle error here...
///         return;
///     }
///     // Use the loaded buffer here...
/// });
/// ```
function bbmod_buffer_load_async(_file, _callback)
{
	var _buffer = buffer_create(1, buffer_grow, 1);
	var _id = buffer_load_async(_buffer, _file, 0, -1);
	global.__bbmodAsyncCallback[? _id] = {
		Buffer: _buffer,
		Callback: _callback,
	};
}

function bbmod_sprite_add_async(_file, _callback)
{
	var _id = sprite_add(_file, 0, false, false, 0, 0);

	if (os_browser == browser_not_a_browser)
	{
		_callback(undefined, _id);
	}
	else
	{
		global.__bbmodSpriteCallback[? _id] = {
			Callback: _callback,
		};
	}
}

/// @func bbmod_async_update(_asyncLoad)
/// @desc
/// @param {ds_map} _asyncLoad The `async_load` map.
function bbmod_async_update(_asyncLoad)
{
	var _map = global.__bbmodAsyncCallback;
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