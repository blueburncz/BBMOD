/// @func BBMOD_Sprite([_file[, _sha1]])
/// @extends BBMOD_Resource
/// @desc A sprite.
/// @param {string} [_file]
/// @param {string} [_sha1]
/// @throws {BBMOD_Exception} When the sprite fails to load.
function BBMOD_Sprite(_file=undefined, _sha1=undefined)
	: BBMOD_Resource() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Resource = {
		destroy: destroy,
	};

	/// @var {sprite/undefined} The raw sprite resource of `undefined` if it
	/// has not been loaded yet.
	/// @readonly
	Raw = undefined;

	/// @var {uint}
	/// @readonly
	Width = 0;

	/// @var {uint}
	/// @readonly
	Height = 0;

	static from_file = function (_file, _sha1=undefined) {
		check_file(_file, _sha1);
		Raw = sprite_add(_file, 1, false, false, 0, 0);
		Width = sprite_get_width(Raw);
		Height = sprite_get_height(Raw);
		IsLoaded = true;
		return self;
	};

	static from_file_async = function (_file, _sha1=undefined, _callback=undefined) {
		if (!check_file(_file, _sha1, _callback ?? bbmod_empty_callback))
		{
			return self;
		}

		var _sprite = self;
		var _struct = {
			Sprite: _sprite,
			Callback: _callback,
		};
		bbmod_sprite_add_async(_file, method(_struct, function (_err, _res) {
			if (_err == undefined)
			{
				Sprite.Raw = _res;
				Sprite.Width = sprite_get_width(_res);
				Sprite.Height = sprite_get_height(_res);
				Sprite.IsLoaded = true;
			}
			if (Callback != undefined)
			{
				Callback(_err, _res);
			}
		}));

		return self;
	};

	/// @func get_texture()
	/// @desc Retrieves a pointer to the texture.
	/// @return {ptr} The pointer to the texture.
	static get_texture = function () {
		gml_pragma("forceinline");
		if (Raw == undefined)
		{
			return -1;
		}
		return sprite_get_texture(Raw, 0);
	};

	static destroy = function () {
		method(self, Super_Resource.destroy)();
		if (Raw != undefined)
		{
			sprite_delete(Raw);
		}
	};

	if (_file != undefined)
	{
		from_file(_file, _sha1);
	}
}