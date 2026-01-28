// Source: https://github.com/kraifpatrik/SponzaTemplate/blob/main/scripts/CGUI/CGUI.gml

/// @func CGUI()
///
/// @desc Shitty UI system for debugging purposes.
function CGUI() constructor
{
	/// @var {String, Undefined}
	/// @readonly
	WidgetActive = undefined;

	/// @var {Real}
	ColumnX = 0;

	/// @var {Real}
	DrawX = 0;

	/// @var {Real}
	DrawY = 0;

	/// @var {Real}
	LineHeight = 18;

	/// @var {Real}
	LineSpacing = 4;

	/// @var {Real}
	MouseX = 0;

	/// @var {Real}
	MouseY = 0;

	/// @var {Bool}
	MouseOverUI = false;

	/// @func SetPosition()
	///
	/// @desc
	///
	/// @param {Real} _x
	/// @param {Real} _y
	///
	/// @return {Struct.CGUI} Returns `self`.
	static SetPosition = function (_x, _y)
	{
		gml_pragma("forceinline");
		DrawX = _x;
		ColumnX = _x;
		DrawY = _y;
		return self;
	};

	/// @func Move(_x[, _y])
	///
	/// @desc
	///
	/// @param {Real} _x
	/// @param {Real} [_y]
	///
	/// @return {Struct.CGUI} Returns `self`.
	static Move = function (_x, _y = 0)
	{
		gml_pragma("forceinline");
		DrawX += _x;
		DrawY += _y;
		return self;
	};

	/// @func Update()
	///
	/// @desc
	///
	/// @return {Struct.CGUI} Returns `self`.
	static Update = function ()
	{
		MouseX = window_mouse_get_x();
		MouseY = window_mouse_get_y();
		MouseOverUI = false;
		return self;
	};

	/// @func Newline([_count])
	///
	/// @desc
	///
	/// @param {Real} [_count]
	///
	/// @return {Struct.CGUI} Returns `self`.
	static Newline = function (_count = 1)
	{
		gml_pragma("forceinline");
		DrawX = ColumnX;
		DrawY += (LineHeight + LineSpacing) * _count;
		return self;
	};

	/// @func DrawTextShadow(_text[, _color[, _alpha[, _shadowColor[, _shadowAlpha]]]])
	///
	/// @desc
	///
	/// @param {String} _text
	/// @param {Constant.Color} [_color]
	/// @param {Real} [_alpha]
	/// @param {Constant.Color} [_shadowColor]
	/// @param {Real} [_shadowAlpha]
	///
	/// @return {Struct.CGUI} Returns `self`.
	static DrawTextShadow = function (_text, _color = c_white, _alpha = 1.0, _shadowColor = c_black, _shadowAlpha = 1.0)
	{
		gml_pragma("forceinline");
		var _textY = DrawY + floor((LineHeight - string_height(_text)) / 2);
		if (_shadowAlpha > 0.0)
		{
			draw_text_color(DrawX + 1, _textY + 1, _text,
				_shadowColor, _shadowColor, _shadowColor, _shadowColor, _shadowAlpha);
		}
		draw_text_color(DrawX, _textY, _text, _color, _color, _color, _color, _alpha);
		return self;
	};

	/// @func Text(_text[, _props])
	///
	/// @desc
	///
	/// @param {String} _text
	/// @param {Struct} [_props]
	///
	/// @return {Struct.CGUI} Returns `self.`
	static Text = function (_text, _props = {})
	{
		var _color = _props[$ "Color"] ?? c_white;
		DrawTextShadow(_text, _color);
		DrawX += string_width(_text);
		return self;
	};

	/// @func Button(_text[, _props])
	///
	/// @desc
	///
	/// @param {String} _text
	/// @param {Struct} [_props]
	///
	/// @return {Struct.CGUI} Returns `self.`
	static Button = function (_text, _props = {})
	{
		var _textWidth = string_width(_text);
		var _backgroundSprite = _props[$ "BackgroundSprite"] ?? SprRoundRect4;
		var _backgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;
		var _backgroundColor = _props[$ "BackgroundColor"] ?? c_dkgray;
		var _width = _props[$ "Width"] ?? (_textWidth + 8);
		var _height = _props[$ "Height"] ?? LineHeight;
		var _onClick = _props[$ "OnClick"];
		var _mouseOver = (MouseX >= DrawX && MouseX <= DrawX + _width
			&& MouseY >= DrawY && MouseY <= DrawY + _height);
		MouseOverUI |= _mouseOver;

		draw_sprite_stretched_ext(
			_backgroundSprite, _backgroundSubimage,
			DrawX, DrawY, _width, _height,
			_backgroundColor, 1.0);
		draw_text(
			DrawX + floor((_width - _textWidth) / 2),
			DrawY + floor((_height - string_height(_text)) / 2),
			_text);

		if (_onClick
			&& mouse_check_button_pressed(mb_left)
			&& _mouseOver)
		{
			_onClick();
		}

		DrawX += _width;

		return self;
	};

	/// @func Checkbox(_checked[, _props])
	///
	/// @desc
	///
	/// @param {Bool} _checked
	/// @param {Struct} [_props]
	///
	/// @return {Struct.CGUI} Returns `self.`
	static Checkbox = function (_checked, _props = {})
	{
		var _label = _props[$ "Label"];
		var _onChange = _props[$ "OnChange"];
		var _backgroundSprite = _props[$ "BackgroundSprite"] ?? SprRoundRect4;
		var _backgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;
		var _backgroundColor = _props[$ "BackgroundColor"] ?? c_dkgray;
		var _fillColor = _props[$ "FillColor"] ?? c_orange;
		var _width = _props[$ "Width"] ?? LineHeight;
		var _height = _props[$ "Height"] ?? LineHeight;
		var _mouseOver = (MouseX >= DrawX && MouseX <= DrawX + _width
			&& MouseY >= DrawY && MouseY <= DrawY + _height);
		MouseOverUI |= _mouseOver;

		draw_sprite_stretched_ext(
			_backgroundSprite, _backgroundSubimage,
			DrawX, DrawY, _width, _height,
			_backgroundColor, 1.0);

		if (_checked)
		{
			draw_sprite_stretched_ext(
				_backgroundSprite, _backgroundSubimage,
				DrawX + 4, DrawY + 4, _width - 8, _height - 8,
				_fillColor, 1.0);
		}

		if (_onChange
			&& mouse_check_button_pressed(mb_left)
			&& _mouseOver)
		{
			_onChange(!_checked);
		}

		DrawX += _width;

		if (_label != undefined)
		{
			DrawX += 8;
			DrawTextShadow(_label);
			DrawX += string_width(_label);
		}

		return self;
	};

	/// @func Slider(_id, _value[, _props])
	///
	/// @desc
	///
	/// @param {String} _id
	/// @param {Real} _value
	/// @param {Struct} [_props]
	///
	/// @return {Struct.CGUI} Returns `self`.
	static Slider = function (_id, _value, _props = {})
	{
		var _min = _props[$ "Min"] ?? 0.0;
		var _max = _props[$ "Max"] ?? 1.0;
		var _factor = (_value - _min) / (_max - _min);
		var _round = _props[$ "Round"] ?? false;
		var _label = _props[$ "Label"];
		var _onChange = _props[$ "OnChange"];
		var _backgroundSprite = _props[$ "BackgroundSprite"] ?? SprRoundRect4;
		var _backgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;
		var _backgroundColor = _props[$ "BackgroundColor"] ?? c_dkgray;
		var _fillColor = _props[$ "FillColor"] ?? c_orange;
		var _width = _props[$ "Width"] ?? 200;
		var _height = _props[$ "Height"] ?? LineHeight;
		var _mouseOver = (MouseX >= DrawX && MouseX <= DrawX + _width
			&& MouseY >= DrawY && MouseY <= DrawY + _height);
		MouseOverUI |= _mouseOver;

		if (WidgetActive == undefined
			&& mouse_check_button_pressed(mb_left)
			&& _mouseOver)
		{
			WidgetActive = _id;
		}

		if (WidgetActive == _id)
		{
			_factor = clamp((MouseX - DrawX) / _width, 0.0, 1.0);
			_value = lerp(_min, _max, _factor);

			if (_round)
			{
				_value = round(_value);
			}

			if (_onChange)
			{
				_onChange(_value);
			}

			if (!mouse_check_button(mb_left))
			{
				WidgetActive = undefined;
			}
		}

		draw_sprite_stretched_ext(
			_backgroundSprite, _backgroundSubimage,
			DrawX, DrawY,
			_width, _height,
			_backgroundColor, 1.0);
		draw_sprite_stretched_ext(
			_backgroundSprite, _backgroundSubimage,
			DrawX + 2, DrawY + 2,
			floor((_width - 4) * _factor), _height - 4,
			_fillColor, 1.0);

		var _text = string(_value);

		draw_text(
			DrawX + floor((_width - string_width(_text)) / 2),
			DrawY + floor((_height - string_height(_text)) / 2),
			_text);

		DrawX += _width;

		if (_label != undefined)
		{
			DrawX += 8;
			DrawTextShadow(_label);
			DrawX += string_width(_label);
		}

		return self;
	};

	/// @func Input(_id, _value[, _props])
	///
	/// @desc
	///
	/// @param {String, Undefined} _id
	/// @param {Real, String} _value
	/// @param {Struct} [_props]
	///
	/// @return {Struct.CGUI} Returns `self`.
	static Input = function (_id, _value, _props = {})
	{
		var _onChange = _props[$ "OnChange"];
		var _backgroundSprite = _props[$ "BackgroundSprite"] ?? SprRoundRect4;
		var _backgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;
		var _backgroundColor = _props[$ "BackgroundColor"] ?? c_dkgray;
		var _width = _props[$ "Width"] ?? 200;
		var _height = _props[$ "Height"] ?? LineHeight;
		var _label = _props[$ "Label"];
		var _mouseOver = (MouseX >= DrawX && MouseX <= DrawX + _width
			&& MouseY >= DrawY && MouseY <= DrawY + _height);
		MouseOverUI |= _mouseOver;
		var _returnValue = false;

		if (WidgetActive == undefined
			&& mouse_check_button_pressed(mb_left)
			&& _mouseOver)
		{
			WidgetActive = _id;
			keyboard_string = string(_value);
		}

		if (_id != undefined
			&& WidgetActive == _id)
		{
			if (keyboard_check_pressed(ord("C"))
				&& keyboard_check(vk_control))
			{
				clipboard_set_text(keyboard_string);
			}
			else if (keyboard_check_pressed(ord("X"))
				&& keyboard_check(vk_control))
			{
				clipboard_set_text(keyboard_string);
				keyboard_string = "";
			}
			else if (keyboard_check_pressed(ord("V"))
				&& keyboard_check(vk_control)
				&& clipboard_has_text())
			{
				keyboard_string += clipboard_get_text();
			}
			else if (keyboard_check_pressed(vk_enter)
				|| (mouse_check_button_pressed(mb_any) && !_mouseOver))
			{
				_returnValue = true;
			}
			else if (keyboard_check_pressed(vk_escape))
			{
				WidgetActive = undefined;
			}
		}

		draw_sprite_stretched_ext(
			_backgroundSprite, _backgroundSubimage,
			DrawX, DrawY,
			_width, _height,
			_backgroundColor, 1.0);

		var _text = (_id != undefined && WidgetActive == _id)
			? keyboard_string : string(_value);

		while (_text != "" && string_width(_text) > _width)
		{
			_text = string_delete(_text, 1, 1);
		}

		var _textWidth = string_width(_text);
		var _textHeight = string_height("Q");
		var _textY = DrawY + floor((_height - _textHeight) / 2);

		draw_text(DrawX, _textY, _text);

		if (_id != undefined
			&& WidgetActive == _id)
		{
			draw_rectangle(
				DrawX + _textWidth,
				_textY,
				DrawX + _textWidth + 1,
				_textY + _textHeight,
				false);
		}

		DrawX += _width;

		if (_label != undefined)
		{
			DrawX += 8;
			DrawTextShadow(_label);
			DrawX += string_width(_label);
		}

		if (_returnValue)
		{
			if (_onChange)
			{
				var _valueNew = _value;
				try
				{
					if (is_real(_value))
					{
						_valueNew = real(keyboard_string);
						var _min = _props[$ "Min"];
						if (_min != undefined)
						{
							_valueNew = max(_valueNew, _min);
						}
						var _max = _props[$ "Max"];
						if (_max != undefined)
						{
							_valueNew = min(_valueNew, _max);
						}
						if (_props[$ "Round"] ?? false)
						{
							_valueNew = round(_valueNew);
						}
					}
					else
					{
						_valueNew = keyboard_string;
					}
				}
				catch (_ignore)
				{}
				_onChange(_valueNew);
			}
			WidgetActive = undefined;
		}

		return self;
	};
}
