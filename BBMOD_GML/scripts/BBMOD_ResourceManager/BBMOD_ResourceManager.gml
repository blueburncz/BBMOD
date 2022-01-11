/// @func BBMOD_ResourceManager()
/// @extends BBMOD_Class
function BBMOD_ResourceManager()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {ds_map<string, BBMOD_Resource>}
	/// @private
	Resources = ds_map_create();

	/// @func get(_path[, _sha1[, _onLoad]])
	///
	/// @desc Asynchronnously loads a resource from a file or retrieves
	/// a reference to it if it is already loaded.
	///
	/// @param {string} _path The path to the resource.
	/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one
	/// does not match with this, then the resource will not be loaded.
	/// @param {function} [_onLoad] A function to execute when the resource is
	/// loaded or if an error occurs while loading it. It must take the error as
	/// the first argument and the resource as the second argument. If no error
	/// occurs, then `undefined` is passed. If the resource was already loaded
	/// when calling this function, then this callback is not executed.
	///
	/// @return {BBMOD_Resource/undefined} The resource.
	///
	/// @note Currently supported files formats are `*.bbmod` for {@link BBMOD_Model},
	/// `*.bbanim` for {@link BBMOD_Animation} and `*.png`, `*.gif`, `*.jpg/jpeg` for
	/// {@link BBMOD_Sprite}.
	static get = function (_path, _sha1=undefined, _onLoad=undefined) {
		var _resources = Resources;

		if (ds_map_exists(_resources, _path))
		{
			return _resources[? _path].ref();
		}

		var _ext = filename_ext(_path);
		var _res;
		switch (_ext)
		{
		case ".bbmod":
			_res = new BBMOD_Model();
			break;

		case ".bbanim":
			_res = new BBMOD_Animation();
			break;

		case ".png":
		case ".gif":
		case ".jpg":
		case ".jpeg":
			_res = new BBMOD_Sprite();
			break;

		default:
			_onLoad(new BBMOD_Exception("Invalid file extension '" + _ext + "'!"));
			return undefined;
		}

		_res.Manager = self;
		_res.from_file_async(_path, _sha1, _onLoad);

		_resources[? _path] = _res;

		return _res;
	};

	/// @func free(_resourceOrPath)
	/// @desc Frees a reference to the resource. When there are no other no other
	/// references, the resource is destroyed.
	/// @param {BBMOD_Resource/string} _resourceOrPath
	/// @return {BBMOD_ResourceManager} Returns `self`.
	static free = function (_resourceOrPath) {
		var _resources = Resources;
		var _path = is_struct(_resourceOrPath)
			? _resourceOrPath.Path
			: _resourceOrPath;
		_resources[? _path].free(); // Note: Resource removes itself from the map
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		var _resources = Resources;
		var _key = ds_map_find_first(_resources);
		repeat (ds_map_size(_resources))
		{
			var _res = _resources[? _key];
			_res.Manager = undefined; // Note: Do not remove resource from the map
			_res.destroy();
			_key = ds_map_find_next(_resources, _key);
		}
		ds_map_destroy(_resources);
	};
}