/// @module Core

/// @macro {Real}
/// @private
#macro __BBMOD_TEXTURE_FORMAT_DEFAULT surface_rgba8unorm

/// @func bbmod_texture_format_to_string(_format)
///
/// @desc Converts a surface format constant to its stable serialization name.
/// Raw texture serialization currently supports only `surface_rgba8unorm`.
///
/// @param {Real} _format The surface format constant.
/// @return {String} The stable format name.
function bbmod_texture_format_to_string(_format)
{
	switch (_format)
	{
		case surface_rgba8unorm:
			return "RGBA8";
		case surface_r8unorm:
			return "R8";
		case surface_rg8unorm:
			return "RG8";
		case surface_r16float:
			return "R16F";
		case surface_r32float:
			return "R32F";
		case surface_rgba16float:
			return "RGBA16F";
		case surface_rgba32float:
			return "RGBA32F";
		default:
			return "";
	}
}

/// @func bbmod_texture_format_from_string(_name)
///
/// @desc Converts a stable serialization name to a surface format constant.
/// Raw texture serialization currently supports only `RGBA8`.
///
/// @param {String} _name The stable format name.
/// @return {Real} The surface format constant, or `undefined` when unsupported.
function bbmod_texture_format_from_string(_name)
{
	switch (string_upper(_name))
	{
		case "RGBA8":
			return surface_rgba8unorm;
		case "R8":
			return surface_r8unorm;
		case "RG8":
			return surface_rg8unorm;
		case "R16F":
			return surface_r16float;
		case "R32F":
			return surface_r32float;
		case "RGBA16F":
			return surface_rgba16float;
		case "RGBA32F":
			return surface_rgba32float;
		default:
			return undefined;
	}
}

/// @func bbmod_texture_format_is_supported(_format)
///
/// @desc Checks whether a texture capture format is supported by the current
/// serialization implementation and runtime. Currently only
/// `surface_rgba8unorm` is supported; other formats are rejected.
///
/// @param {Real} _format The surface format constant.
/// @return {Bool} Whether the format is supported.
function bbmod_texture_format_is_supported(_format)
{
	return (_format == surface_rgba8unorm
		&& surface_format_is_supported(_format));
}

/// @func bbmod_texture_ref_resolve(_texture, _sprite, _subimage)
///
/// @desc Returns the effective texture for a texture reference. The sprite
/// source takes precedence over the texture when it is defined.
///
/// @param {Pointer.Texture} _texture The fallback texture.
/// @param {Asset.GMSprite} _sprite The optional sprite source.
/// @param {Real} _subimage The sprite subimage to use.
///
/// @return {Pointer.Texture} The selected texture.
function bbmod_texture_ref_resolve(_texture, _sprite, _subimage)
{
	gml_pragma("forceinline");
	if (_sprite != undefined)
	{
		return sprite_get_texture(_sprite, _subimage);
	}
	return _texture;
}

/// @func bbmod_texture_ref_destroy(_owner, _name)
///
/// @desc Deletes an owned sprite reference and clears its companion fields.
///
/// @param {Struct} _owner The struct containing the texture reference fields.
/// @param {String} _name The base name of the texture field.
///
/// @return {Struct} Returns `_owner`.
function bbmod_texture_ref_destroy(_owner, _name)
{
	var _spriteName = _name + "Sprite";
	if (_owner[$ (_name + "Owned")] && _owner[$  _spriteName] != undefined)
	{
		sprite_delete(_owner[$  _spriteName]);
	}
	_owner[$  _spriteName] = undefined;
	_owner[$ (_name + "Subimage")] = 0;
	_owner[$ (_name + "Owned")] = false;
	return _owner;
}

/// @func bbmod_texture_ref_copy(_source, _destination, _name)
///
/// @desc Copies a texture reference. Owned sprites are duplicated so the
/// destination can destroy its copy independently.
///
/// @param {Struct} _source The source struct.
/// @param {Struct} _destination The destination struct.
/// @param {String} _name The base name of the texture field.
///
/// @return {Struct} Returns `_destination`.
function bbmod_texture_ref_copy(_source, _destination, _name)
{
	bbmod_texture_ref_destroy(_destination, _name);
	_destination[$  _name] = _source[$  _name];
	_destination[$ (_name + "Subimage")] = _source[$ (_name + "Subimage")];
	_destination[$ (_name + "Format")] = _source[$ (_name + "Format")]
		?? __BBMOD_TEXTURE_FORMAT_DEFAULT;
	if (_source[$ (_name + "Sprite")] != undefined)
	{
		_destination[$ (_name + "Sprite")] = _source[$ (_name + "Owned")]
			? sprite_duplicate(_source[$ (_name + "Sprite")])
			: _source[$ (_name + "Sprite")];
		_destination[$ (_name + "Owned")] = _source[$ (_name + "Owned")];
	}
	return _destination;
}

/// @func bbmod_texture_ref_to_json(_json, _owner, _name)
///
/// @desc Serializes a texture reference using the existing `__Textures`
/// format. Runtime-created sprites and pointer-only textures are captured as
/// raw RGBA8 data. Other capture formats are rejected.
///
/// @param {Struct} _json The JSON object receiving the material properties.
/// @param {Struct} _owner The struct containing the texture reference fields.
/// @param {String} _name The base name of the texture field.
///
/// @return {Struct} Returns `_json`.
///
/// @throws {BBMOD_Exception} If a sprite reference has no asset-backed name.
function bbmod_texture_ref_to_json(_json, _owner, _name)
{
	_json[$  _name] = _owner[$  _name];
	var _format = _owner[$ (_name + "Format")]
		?? __BBMOD_TEXTURE_FORMAT_DEFAULT;
	_json[$ (_name + "Format")] = bbmod_texture_format_to_string(_format);
	var _sprite = _owner[$ (_name + "Sprite")];
	if (_sprite == undefined)
	{
		var _texture = _owner[$  _name];
		if (_texture != undefined && _texture != (-1 /*pointer_null*/ ))
		{
			if (!variable_struct_exists(_json, "__Textures"))
			{
				_json.__Textures = {};
			}
			_json.__Textures[$  _name] = __bbmod_texture_ref_to_raw(
				_texture, _format);
		}
		return _json;
	}
	if (!variable_struct_exists(_json, "__Textures"))
	{
		_json.__Textures = {};
	}
	if (variable_struct_exists(_owner, "__texturePaths")
		&& variable_struct_exists(_owner.__texturePaths, _name))
	{
		_json.__Textures[$  _name] = _owner.__texturePaths[$  _name];
		return _json;
	}

	var _spriteName = sprite_get_name(_sprite);
	if (asset_get_index(_spriteName) == -1)
	{
		_json.__Textures[$  _name] = __bbmod_texture_ref_to_raw(
			bbmod_texture_ref_resolve(
				_owner[$  _name], _sprite, _owner[$ (_name + "Subimage")]),
			_format);
		return _json;
	}

	_json.__Textures[$  _name] = "sprite://"
		+ _spriteName + ":" + string(_owner[$ (_name + "Subimage")]);
	return _json;
}

/// @func __bbmod_texture_ref_to_raw(_texture, _format)
///
/// @desc Captures a texture into a versioned RGBA8 JSON-safe texture payload.
///
/// @param {Pointer.Texture} _texture The texture to capture.
/// @param {SurfaceFormatType} _format The requested capture format.
///
/// @return {Struct} The raw texture payload.
///
/// @private
function __bbmod_texture_ref_to_raw(_texture, _format)
{
	if (_format != surface_rgba8unorm
		|| !surface_format_is_supported(_format))
	{
		throw new BBMOD_Exception("Only supported RGBA8 texture capture is available.");
	}

	var _uvs = texture_get_uvs(_texture);
	var _texelWidth = texture_get_texel_width(_texture);
	var _texelHeight = texture_get_texel_height(_texture);
	var _width = round((_uvs[2] - _uvs[0]) / _texelWidth);
	var _height = round((_uvs[3] - _uvs[1]) / _texelHeight);

	if (_width <= 0 || _height <= 0)
	{
		throw new BBMOD_Exception("Texture has invalid capture dimensions.");
	}

	var _world = matrix_get(matrix_world);
	var _view = matrix_get(matrix_view);
	var _projection = matrix_get(matrix_projection);
	var _surface = bbmod_surface_check(-1, _width, _height, _format, false);

	gpu_push_state();
	gpu_set_state(bbmod_gpu_get_default_state());
	matrix_set(matrix_world, matrix_build_identity());
	matrix_set(matrix_view, matrix_build_identity());
	matrix_set(matrix_projection,
		matrix_build_projection_ortho(_width, _height, 0.0, 1.0));
	surface_set_target(_surface);
	draw_clear_alpha(c_black, 0.0);
	draw_primitive_begin_texture(pr_trianglelist, _texture);
	draw_vertex_texture(0, 0, _uvs[0], _uvs[1]);
	draw_vertex_texture(_width, 0, _uvs[2], _uvs[1]);
	draw_vertex_texture(_width, _height, _uvs[2], _uvs[3]);
	draw_vertex_texture(0, 0, _uvs[0], _uvs[1]);
	draw_vertex_texture(_width, _height, _uvs[2], _uvs[3]);
	draw_vertex_texture(0, _height, _uvs[0], _uvs[3]);
	draw_primitive_end();
	surface_reset_target();
	matrix_set(matrix_world, _world);
	matrix_set(matrix_view, _view);
	matrix_set(matrix_projection, _projection);
	gpu_pop_state();

	var _buffer = buffer_create(_width * _height * 4, buffer_fast, 1);
	buffer_get_surface(_buffer, _surface, 0);
	surface_free(_surface);

	var _data = array_create(_width * _height * 4, 0);
	buffer_seek(_buffer, buffer_seek_start, 0);
	for (var i = 0; i < array_length(_data); ++i)
	{
		_data[i] = buffer_read(_buffer, buffer_u8);
	}
	buffer_delete(_buffer);

	return {
		Kind: "Raw",
		Version: 1,
		Width: _width,
		Height: _height,
		Format: bbmod_texture_format_to_string(_format),
		Data: _data,
	};
}

/// @func __bbmod_texture_ref_from_raw(_raw)
///
/// @desc Reconstructs an owned sprite from a raw RGBA8 texture payload.
///
/// @param {Struct} _raw The raw texture payload.
///
/// @return {Asset.GMSprite} The reconstructed sprite.
///
/// @throws {BBMOD_Exception} If the payload is invalid or unsupported.
/// @private
function __bbmod_texture_ref_from_raw(_raw)
{
	if (_raw.Version != 1 || _raw.Format != "RGBA8")
	{
		throw new BBMOD_Exception("Unsupported raw texture format or version!");
	}

	var _width = _raw.Width;
	var _height = _raw.Height;
	var _data = _raw.Data;
	if (_width <= 0 || _height <= 0 || array_length(_data) != _width * _height * 4)
	{
		throw new BBMOD_Exception("Invalid raw texture dimensions or data!");
	}

	var _buffer = buffer_create(array_length(_data), buffer_fast, 1);
	for (var i = 0; i < array_length(_data); ++i)
	{
		buffer_write(_buffer, buffer_u8, _data[i]);
	}
	var _surface = bbmod_surface_check(-1, _width, _height, surface_rgba8unorm, false);
	buffer_set_surface(_buffer, _surface, 0);
	var _sprite = sprite_create_from_surface(
		_surface, 0, 0, _width, _height, false, false, 0, 0);
	buffer_delete(_buffer);
	surface_free(_surface);
	return _sprite;
}

/// @func bbmod_texture_ref_from_json(_json, _owner, _name)
///
/// @desc Expands an existing `__Textures` entry into a texture reference.
/// Asset-backed `sprite://` paths are resolved directly. File-backed paths use
/// the owner's resource manager and path when available.
///
/// @param {Struct} _json The JSON object containing the texture manifest.
/// @param {Struct} _owner The struct receiving the texture reference fields.
/// @param {String} _name The base name of the texture field.
///
/// @return {Bool} Returns `true` when the reference was applied.
///
/// @throws {BBMOD_Exception} If a referenced texture cannot be resolved.
function bbmod_texture_ref_from_json(_json, _owner, _name)
{
	if (variable_struct_exists(_json, _name + "Sprite"))
	{
		bbmod_texture_ref_destroy(_owner, _name);
		_owner[$  _name] = _json[$  _name];
		_owner[$ (_name + "Sprite")] = _json[$ (_name + "Sprite")];
		_owner[$ (_name + "Format")] = bbmod_texture_format_from_string(
			_json[$ (_name + "Format")]) ?? __BBMOD_TEXTURE_FORMAT_DEFAULT;
		_owner[$ (_name + "Subimage")] = variable_struct_exists(
			_json, _name + "Subimage") ? _json[$ (_name + "Subimage")] : 0;
		_owner[$ (_name + "Owned")] = false;
		if (variable_struct_exists(_json, "__Textures")
			&& variable_struct_exists(_json.__Textures, _name))
		{
			if (!variable_struct_exists(_owner, "__texturePaths"))
			{
				_owner.__texturePaths = {};
			}
			var _source = _json.__Textures[$  _name];
			_owner.__texturePaths[$  _name] = is_string(_source)
				? _source : _source.Path;
		}
		return true;
	}
	if (!variable_struct_exists(_json, "__Textures"))
	{
		if (variable_struct_exists(_json, _name))
		{
			bbmod_texture_ref_destroy(_owner, _name);
			_owner[$  _name] = _json[$  _name];
			_owner[$ (_name + "Owned")] = false;
			_owner[$ (_name + "Format")] = bbmod_texture_format_from_string(
				_json[$ (_name + "Format")]) ?? __BBMOD_TEXTURE_FORMAT_DEFAULT;
			return true;
		}
		return false;
	}

	var _textures = _json.__Textures;
	if (!variable_struct_exists(_textures, _name))
	{
		return false;
	}

	var _propertyValue = _textures[$  _name];
	if (is_struct(_propertyValue)
		&& variable_struct_exists(_propertyValue, "Kind")
		&& _propertyValue.Kind == "Raw")
	{
		var _rawSprite = __bbmod_texture_ref_from_raw(_propertyValue);
		bbmod_texture_ref_destroy(_owner, _name);
		_owner[$  _name] = sprite_get_texture(_rawSprite, 0);
		_owner[$ (_name + "Sprite")] = _rawSprite;
		_owner[$ (_name + "Subimage")] = 0;
		_owner[$ (_name + "Owned")] = true;
		_owner[$ (_name + "Format")] = bbmod_texture_format_from_string(
			_propertyValue.Format) ?? __BBMOD_TEXTURE_FORMAT_DEFAULT;
		return true;
	}
	var _texturePath = is_string(_propertyValue)
		? _propertyValue : _propertyValue.Path;
	var _textureSha1 = is_string(_propertyValue)
		? undefined : _propertyValue[$ "SHA1"];
	var _subimage = 0;
	var _sprite = undefined;
	var _owned = false;

	if (string_starts_with(_texturePath, "sprite://"))
	{
		var _parts = string_split(string_delete(_texturePath, 1, 9), ":");
		var _spriteName = _parts[0];
		if (array_length(_parts) > 1)
		{
			_subimage = real(_parts[1]);
		}
		_sprite = asset_get_index(_spriteName);
		if (_sprite == -1)
		{
			throw new BBMOD_Exception("Invalid texture " + _spriteName + "!");
		}
	}
	else
	{
		if (variable_struct_exists(_owner, "__manager")
			&& _owner.__manager != undefined)
		{
			var _basePath = variable_struct_exists(_owner, "Path")
				? filename_dir(_owner.Path) : "";
			_texturePath = bbmod_path_get_absolute(_texturePath, _basePath);
			_sprite = _owner.__manager.load_sync(_texturePath, _textureSha1);
			_sprite = _sprite.Raw;
		}
		else
		{
			var _resource = new BBMOD_Sprite(_texturePath, _textureSha1);
			_sprite = _resource.Raw;
			_resource.Owned = false;
			_owned = true;
		}
	}

	if (!variable_struct_exists(_owner, "__texturePaths"))
	{
		_owner.__texturePaths = {};
	}
	_owner.__texturePaths[$  _name] = _texturePath;

	bbmod_texture_ref_destroy(_owner, _name);
	_owner[$  _name] = sprite_get_texture(_sprite, _subimage);
	_owner[$ (_name + "Sprite")] = _sprite;
	_owner[$ (_name + "Subimage")] = _subimage;
	_owner[$ (_name + "Owned")] = _owned;
	_owner[$ (_name + "Format")] = bbmod_texture_format_from_string(
		_json[$ (_name + "Format")]) ?? __BBMOD_TEXTURE_FORMAT_DEFAULT;
	return true;
}
