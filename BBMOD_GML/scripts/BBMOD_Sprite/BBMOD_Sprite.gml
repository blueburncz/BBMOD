/// @module Core

/// @func BBMOD_Sprite([_file[, _sha1]])
///
/// @extends BBMOD_Resource
///
/// @desc A sprite.
///
/// @param {String} [_file] The file to load the sprite from or `undefined`.
/// @param {String} [_sha1] Expected SHA1 of the file. If the actual  one does
/// not match with this, then the model will not be loaded. Use `undefined` if
/// you do not want to check the SHA1 of the file.
///
/// @throws {BBMOD_Exception} When the sprite fails to load.
function BBMOD_Sprite(_file = undefined, _sha1 = undefined): BBMOD_Resource() constructor
{
	static Resource_destroy = destroy;

	/// @var {Asset.GMSprite} The raw sprite resource of `undefined` if it
	/// has not been loaded yet.
	/// @readonly
	Raw = undefined;

	/// @var {Bool} Whether `Raw` stores a sprite owned by this struct. If
	/// `true`, then the sprite is deleted when the struct is destroyed. Default
	/// value is `true`.
	Owned = true;

	/// @var {Real} The width of the sprite.
	/// @readonly
	Width = 0;

	/// @var {Real} The height of the sprite.
	/// @readonly
	Height = 0;

	static from_file = function (_file, _sha1 = undefined)
	{
		Path = _file;
		__check_file(_file, _sha1);
		Raw = sprite_add(_file, 1, false, false, 0, 0);
		Width = sprite_get_width(Raw);
		Height = sprite_get_height(Raw);
		IsLoaded = true;
		return self;
	};

	static from_file_async = function (_file, _sha1 = undefined, _callback = undefined)
	{
		Path = _file;

		if (!__check_file(_file, _sha1, _callback ?? bbmod_empty_callback))
		{
			return self;
		}

		var _sprite = self;
		var _struct = {
			Sprite: _sprite,
			Callback: _callback,
		};
		bbmod_sprite_add_async(_file, method(_struct, function (_err, _res)
		{
			if (_err == undefined)
			{
				Sprite.Raw = _res;
				Sprite.Width = sprite_get_width(_res);
				Sprite.Height = sprite_get_height(_res);
				Sprite.IsLoaded = true;
			}
			if (Callback)
			{
				Callback(_err, Sprite);
			}
		}));

		return self;
	};

	static to_file = function (_file)
	{
		var _dirname = filename_dir(_file);
		if (!directory_exists(_dirname))
		{
			directory_create(_dirname);
		}
		sprite_save_strip(Raw, _file);
		return self;
	};

	/// @func get_texture([_subimage])
	///
	/// @desc Retrieves a pointer to the texture.
	///
	/// @param {Real} [_subimage] The sprite subimage to retrieve the texture of.
	/// Defaults to 0.
	///
	/// @return {Pointer.Texture} The pointer to the texture.
	static get_texture = function (_subimage = 0)
	{
		gml_pragma("forceinline");
		if (Raw == undefined)
		{
			return (-1/*pointer_null*/);
		}
		return sprite_get_texture(Raw, _subimage);
	};

	static destroy = function ()
	{
		Resource_destroy();
		if (Owned && Raw != undefined)
		{
			sprite_delete(Raw);
		}
		Raw = undefined;
		return undefined;
	};

	if (_file != undefined)
	{
		from_file(_file, _sha1);
	}
}
