var _window_width = max(window_get_width(), 1);
var _window_height = max(window_get_height(), 1);

var _surface_width = max(_window_width * application_surface_scale, 1);
var _surface_height = max(_window_height * application_surface_scale, 1);

if (surface_get_width(application_surface) != _surface_width
	|| surface_get_height(application_surface) != _surface_height)
{
	surface_resize(application_surface, _surface_width, _surface_height);
}

// Mouselook
var _mouse_x = window_mouse_get_x();
var _mouse_y = window_mouse_get_y();
var _mouse_sensitivity = 1;

if (mouse_check_button(mb_right))
{
	direction += (mouse_last_x - _mouse_x) * _mouse_sensitivity;
	direction_up += (mouse_last_y - _mouse_y) * _mouse_sensitivity;
}

mouse_last_x = _mouse_x;
mouse_last_y = _mouse_y;

// Move around
var _move_speed = keyboard_check(vk_shift) ? 1 : 0.25;

if (keyboard_check(ord("W")))
{
	x += lengthdir_x(_move_speed, direction);
	y += lengthdir_y(_move_speed, direction);
}
else if (keyboard_check(ord("S")))
{
	x -= lengthdir_x(_move_speed, direction);
	y -= lengthdir_y(_move_speed, direction);
}

if (keyboard_check(ord("A")))
{
	x += lengthdir_x(_move_speed, direction + 90);
	y += lengthdir_y(_move_speed, direction + 90);
}
else if (keyboard_check(ord("D")))
{
	x += lengthdir_x(_move_speed, direction - 90);
	y += lengthdir_y(_move_speed, direction - 90);
}

z += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * _move_speed;

// Controls
var _strength = keyboard_check(vk_shift) ? 1 : 0.1;
var _diff = (mouse_wheel_up() - mouse_wheel_down()) * _strength;

if (keyboard_check(ord("R")))
{
	roughness += _diff * 0.1;
	roughness = clamp(roughness, 0, 1);
}
else
{
	exposure += _diff;
	exposure = max(exposure, 0.1);
}