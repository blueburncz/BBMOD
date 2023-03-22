/// @func DrawTextShadow(_x, _y, _text[, _color[, _colorShadow[, _alpha]]])
///
/// @desc Draws a text with a shadow.
///
/// @param {Real} _x The x position of the text.
/// @param {Real} _y The y position of the text.
/// @param {String} _text The text to draw.
/// @param {Constant.Color} [_color] The color of the text. Defaults to white.
/// @param {Constant.Color} [_colorShadow] The color of the shadow. Defaults to
/// black.
/// @param {Real} [_alpha] The alpha of both the text and its shadow. Defaults
/// to 1.
function DrawTextShadow(
	_x, _y, _text, _color=c_white, _colorShadow=c_black, _alpha=1.0)
{
	gml_pragma("forceinline");
	draw_text_color(_x + 2, _y + 2, _text,
		_colorShadow, _colorShadow, _colorShadow, _colorShadow, _alpha);
	draw_text_color(_x, _y, _text, _color, _color, _color, _color, _alpha);
}
