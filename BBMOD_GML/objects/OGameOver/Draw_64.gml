var _windowWidth = window_get_width();
var _windowHeight = window_get_height();
var _font = draw_get_font();
var _lineHeight, _x, _y;

draw_set_halign(fa_center);

draw_set_font(Fnt48);
_lineHeight = string_height("Q");
_x = round(_windowWidth * 0.5);
_y = round(_windowHeight * 0.5) - _lineHeight * 2.0;
DrawTextShadow(_x, _y, "Game Over");
_y += _lineHeight;

draw_set_font(Fnt24);
_lineHeight = string_height("Q");
DrawTextShadow(_x, _y, "Score: " + string(score + global.scoreBonus));
_y += _lineHeight * 2.0;

draw_set_font(Fnt16);
_lineHeight = string_height("Q");
DrawTextShadow(_x, _y, "Zombie kills: " + string(score));
_y += _lineHeight;

DrawTextShadow(_x, _y, "Time bonus: " + string(global.scoreBonus));
_y += _lineHeight * 2.0;

draw_set_font(Fnt24);
_lineHeight = string_height("Q");
DrawTextShadow(_x, _y, "Press LMB to try again");
_y += _lineHeight * 2.0;

draw_set_font(_font);
draw_set_halign(fa_left);