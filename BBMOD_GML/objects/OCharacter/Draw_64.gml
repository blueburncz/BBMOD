var _wheel = (mouse_wheel_up() - mouse_wheel_down()) * 0.1;
if (keyboard_check(ord("Z"))) layerWalk.Weight = clamp(layerWalk.Weight + _wheel, 0.0, 1.0);
if (keyboard_check(ord("X"))) layerWalk.SpeedMultiplier = clamp(layerWalk.SpeedMultiplier + _wheel, -2.0, 2.0);
if (keyboard_check(ord("C"))) layerShoot.Weight = clamp(layerShoot.Weight + _wheel, 0.0, 1.0);
if (keyboard_check(ord("V"))) layerJump.Weight = clamp(layerJump.Weight + _wheel, 0.0, 1.0);

var _text = ""
	+ $"Walk: {layerWalk.Weight}\n"
	+ $"WalkSpeed: {layerWalk.SpeedMultiplier}\n"
	+ $"Shoot: {layerShoot.Weight}\n"
	+ $"Jump: {layerJump.Weight}\n";
draw_text(bbmod_window_get_width() / 2, bbmod_window_get_height() / 2, _text);
