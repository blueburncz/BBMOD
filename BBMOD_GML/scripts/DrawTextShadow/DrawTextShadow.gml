/// @func DrawTextShadow(_x, _y, _text[, _color[, _colorShadow[, _alpha]]])
/// @desc Draws a text with a shadow.
/// @param {real} _x The x position of the text.
/// @param {real} _y The y position of the text.
/// @param {string} _text The text to draw.
/// @param {uint32} [_color] The color of the text. Defaults to white.
/// @param {uint32} [_colorShadow] The color of the shadow. Defaults to black.
/// @param {real} [_alpha] The alpha of both the text and its shadow. Defaults to 1.
function DrawTextShadow(_x, _y, _text, _color=c_white, _colorShadow=c_black, _shadow=1)
{
	gml_pragma("forceinline");
	draw_text_color(_x + 2, _y + 2, _text, _colorShadow, _colorShadow, _colorShadow, _colorShadow, _shadow);
	draw_text_color(_x, _y, _text, _color, _color, _color, _color, _shadow);
}