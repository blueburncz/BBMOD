/// @module PostProcessing

/// @func BBMOD_LensFlareElement([_sprite[, _subimage[, _offset[, _scale[, _scaleByDistanceMin[, _scaleByDistanceMax[, _color[, _applyTint[, _angle[, _angleRelative[, _fadeOut[, _applyStarburst[, _spriteOwned]]]]]]]]]]]]])
///
/// @implements {BBMOD_IDestructible}
///
/// @desc A single lens flare element (sprite).
///
/// @param {Asset.GMSprite} [_sprite] The sprite of the lens flare element.
/// Defaults to `BBMOD_SprLensFlareHeptagon`.
/// @param {Real} [_subimage] The sprite subimage. Defaults to 0.
/// @param {Struct.BBMOD_Vec2} [_offset] The offset from the lights position on
/// the screen, where `(0, 0)` is the light's position, `(0.5, 0.5)` is the
/// screen center and `(1, 1)` is the lights position inverted around the screen
/// center. Defaults to `(0, 0)` if `undefined`.
/// @param {Struct.BBMOD_Vec2} [_scale] The scale of the lens flare sprite.
/// Defaults to `(1, 1)` if `undefined`.
/// @param {Struct.BBMOD_Vec2} [_scaleByDistanceMin] Scale multiplier when the
/// lens flare's normalized distance from the light's position on screen is 0.
/// Defaults to `(1, 1)` if `undefined`.
/// @param {Struct.BBMOD_Vec2} [_scaleByDistanceMax] Scale multiplier when the
/// lens flare's normalized distance from the light's position on screen is 1.
/// Defaults to `(1, 1)` if `undefined`.
/// @param {Struct.BBMOD_Color} [_color] The color of the lens flare. Defaults
/// to {@link BBMOD_C_WHITE} if `undefined`.
/// @param {Bool} [_applyTint] If `true` then {@link BBMOD_LensFlare.Tint} is
/// applied to `Color`. Defaults to `true`.
/// @param {Real} [_angle] The rotation of the lens flare. Defaults to 0.
/// @param {Bool} [_angleRelative] If `true` then the lens flare angle is
/// relative to the direction to the light's position on screen. Defaults to
/// `false`.
/// @param {Bool} [_fadeOut] Whether to fade out the lens flare on screen edges.
/// Defaults to `false`.
/// @param {Bool} [_applyStarburst] Whether to apply starburst. Defaults to
/// `false`.
/// @param {Bool} [_spriteOwned] Whether this element owns `_sprite` and deletes
/// it when destroyed. Defaults to `false`.
///
/// @see BBMOD_LensFlare
/// @see BBMOD_PostProcessor.Starburst
function BBMOD_LensFlareElement(
	_sprite = BBMOD_SprLensFlareHeptagon,
	_subimage = 0,
	_offset = undefined,
	_scale = undefined,
	_scaleByDistanceMin = undefined,
	_scaleByDistanceMax = undefined,
	_color = undefined,
	_applyTint = false,
	_angle = 0.0,
	_angleRelative = false,
	_fadeOut = false,
	_applyStarburst = false,
	_spriteOwned = false
) constructor
{
	/// @var {Asset.GMSprite} The sprite of the lens flare element. Default
	/// value is `BBMOD_SprLensFlareHeptagon`.
	Sprite = _sprite;

	/// @var {Bool} Whether this element owns
	/// {@link BBMOD_LensFlareElement.Sprite}. Owned sprites are
	/// deleted when the element is destroyed. Defaults to `false`.
	SpriteOwned = _spriteOwned;

	/// @var {String} External sprite file used during serialization, or
	/// `undefined` (default).
	SpritePath = undefined;

	/// @var {String} Optional SHA1 for {@link SpritePath}, or `undefined`
	/// (default).
	SpriteSha1 = undefined;

	/// @var {Real} The sprite subimage. Default value is 0.
	Subimage = _subimage;

	/// @var {Struct.BBMOD_Vec2} The offset from the lights position on the
	/// screen, where `(0, 0)` is the light's position, `(0.5, 0.5)` is the
	/// screen center and `(1, 1)` is the lights position inverted around the
	/// screen center. Default value is `(0, 0)`.
	Offset = _offset ?? new BBMOD_Vec2();

	/// @var {Struct.BBMOD_Vec2} The scale of the lens flare sprite. Default
	/// value is to `(1, 1)`.
	Scale = _scale ?? new BBMOD_Vec2(1.0);

	/// @var {Struct.BBMOD_Vec2} Scale multiplier when the lens flare's
	/// normalized distance from the light's position on screen is 0. Default
	/// value is `(1, 1)`.
	ScaleByDistanceMin = _scaleByDistanceMin ?? new BBMOD_Vec2(1.0);

	/// @var {Struct.BBMOD_Vec2} Scale multiplier when the lens flare's
	/// normalized distance from the light's position on screen is 1. Default
	/// value is `(1, 1)`.
	ScaleByDistanceMax = _scaleByDistanceMax ?? new BBMOD_Vec2(1.0);

	/// @var {Struct.BBMOD_Color} The color of the lens flare. Default value is
	/// {@link BBMOD_C_WHITE}.
	Color = _color ?? BBMOD_C_WHITE;

	/// @var {Bool} If `true` then {@link BBMOD_LensFlare.Tint} is applied to
	/// `Color`. Default value is `true`.
	/// @see BBMOD_LensFlareElement.Color
	ApplyTint = true;

	/// @var {Real} The rotation of the lens flare. Default value is 0.
	Angle = _angle;

	/// @var {Bool} If `true` then the lens flare angle is relative to the
	/// direction to the light's position on screen. Default value is `false`.
	AngleRelative = _angleRelative;

	/// @var {Bool} Whether to fade out the lens flare on screen edges. Default
	/// value is `false`.
	FadeOut = _fadeOut;

	/// @var {Bool} Whether to apply starburst. Default value is `false`.
	ApplyStarburst = _applyStarburst;

	static __write_sprite = function (_buffer)
	{
		if (Sprite == undefined)
		{
			buffer_write(_buffer, buffer_u8, 0);
			return;
		}

		if (SpritePath != undefined)
		{
			buffer_write(_buffer, buffer_u8, 2);
			buffer_write(_buffer, buffer_string, SpritePath);
			buffer_write(_buffer, buffer_string, SpriteSha1 ?? "");
			return;
		}

		var _name = sprite_get_name(Sprite);
		var _asset = (_name != "") ? asset_get_index(_name) : -1;
		if (!SpriteOwned && _asset != -1 && asset_get_type(_asset) == asset_sprite)
		{
			buffer_write(_buffer, buffer_u8, 1);
			buffer_write(_buffer, buffer_string, _name);
			return;
		}

		var _raw = __bbmod_texture_ref_to_raw(
			sprite_get_texture(Sprite, Subimage), surface_rgba8unorm);
		buffer_write(_buffer, buffer_u8, 3);
		buffer_write(_buffer, buffer_u32, _raw.Width);
		buffer_write(_buffer, buffer_u32, _raw.Height);
		buffer_write(_buffer, buffer_u32, array_length(_raw.Data));
		for (var i = 0; i < array_length(_raw.Data); ++i)
		{
			buffer_write(_buffer, buffer_u8, _raw.Data[i]);
		}
	};

	static __read_sprite = function (_buffer)
	{
		var _kind = buffer_read(_buffer, buffer_u8);
		if (_kind == 0)
		{
			return { Sprite: undefined, Owned: false };
		}

		if (_kind == 1)
		{
			var _name = buffer_read(_buffer, buffer_string);
			var _asset = asset_get_index(_name);
			if (_asset == -1)
			{
				throw new BBMOD_Exception("Missing lens flare sprite: " + _name);
			}
			return { Sprite: _asset, Owned: false };
		}

		if (_kind == 2)
		{
			var _path = buffer_read(_buffer, buffer_string);
			var _sha1 = buffer_read(_buffer, buffer_string);
			var _resource = new BBMOD_Sprite(
				_path, _sha1 == "" ? undefined : _sha1);
			return {
				Sprite: _resource.Raw,
				Owned: true,
				Path: _path,
				SHA1: _sha1,
			};
		}

		if (_kind == 3)
		{
			var _width = buffer_read(_buffer, buffer_u32);
			var _height = buffer_read(_buffer, buffer_u32);
			var _length = buffer_read(_buffer, buffer_u32);
			if (_width <= 0 || _height <= 0 || _length != _width * _height * 4)
			{
				throw new BBMOD_Exception("Invalid embedded lens flare sprite.");
			}
			var _data = array_create(_length, 0);
			for (var i = 0; i < _length; ++i)
			{
				_data[i] = buffer_read(_buffer, buffer_u8);
			}
			return {
				Sprite: __bbmod_texture_ref_from_raw(
				{
					Version: 1,
					Format: "RGBA8",
					Width: _width,
					Height: _height,
					Data: _data,
				}),
				Owned: true,
			};
		}

		throw new BBMOD_Exception("Unknown lens flare sprite source.");
	};

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes this element's source and configuration to a binary buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write to.
	///
	/// @return {Struct.BBMOD_LensFlareElement} Returns `self`.
	static to_buffer = function (_buffer)
	{
		__write_sprite(_buffer);
		buffer_write(_buffer, buffer_f64, Subimage);
		Offset.ToBuffer(_buffer, buffer_f64);
		Scale.ToBuffer(_buffer, buffer_f64);
		ScaleByDistanceMin.ToBuffer(_buffer, buffer_f64);
		ScaleByDistanceMax.ToBuffer(_buffer, buffer_f64);
		Color.ToBuffer(_buffer);
		buffer_write(_buffer, buffer_bool, ApplyTint);
		buffer_write(_buffer, buffer_f64, Angle);
		buffer_write(_buffer, buffer_bool, AngleRelative);
		buffer_write(_buffer, buffer_bool, FadeOut);
		buffer_write(_buffer, buffer_bool, ApplyStarburst);
		return self;
	};

	/// @func from_buffer(_buffer)
	///
	/// @desc Reads this element's source and configuration from a binary buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to read from.
	///
	/// @return {Struct.BBMOD_LensFlareElement} Returns `self`.
	static from_buffer = function (_buffer)
	{
		var _sprite = __read_sprite(_buffer);
		Sprite = _sprite.Sprite;
		SpriteOwned = _sprite.Owned;
		SpritePath = variable_struct_exists(_sprite, "Path")
			? _sprite.Path : undefined;
		SpriteSha1 = variable_struct_exists(_sprite, "SHA1")
			? _sprite.SHA1 : undefined;
		Subimage = buffer_read(_buffer, buffer_f64);
		Offset = new BBMOD_Vec2().FromBuffer(_buffer, buffer_f64);
		Scale = new BBMOD_Vec2().FromBuffer(_buffer, buffer_f64);
		ScaleByDistanceMin = new BBMOD_Vec2().FromBuffer(_buffer, buffer_f64);
		ScaleByDistanceMax = new BBMOD_Vec2().FromBuffer(_buffer, buffer_f64);
		Color = new BBMOD_Color().FromBuffer(_buffer);
		ApplyTint = buffer_read(_buffer, buffer_bool);
		Angle = buffer_read(_buffer, buffer_f64);
		AngleRelative = buffer_read(_buffer, buffer_bool);
		FadeOut = buffer_read(_buffer, buffer_bool);
		ApplyStarburst = buffer_read(_buffer, buffer_bool);
		return self;
	};

	/// @func destroy()
	///
	/// @desc Deletes the element sprite when this element owns it.
	///
	/// @return {Undefined} Always returns `undefined`.
	static destroy = function ()
	{
		if (SpriteOwned && Sprite != undefined)
		{
			sprite_delete(Sprite);
		}
		return undefined;
	};
}
