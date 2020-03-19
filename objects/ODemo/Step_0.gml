var _mouse_x = window_mouse_get_x();
var _mouse_y = window_mouse_get_y();
var _mouse_sens = 1;

if (mouse_check_button(mb_right))
{
	direction += (mouse_last_x - _mouse_x) * _mouse_sens;
	cam_pitch -= (mouse_last_y - _mouse_y) * _mouse_sens;
	cam_pitch = clamp(cam_pitch, -89.99, 89.99);
}

cam_zoom = max(cam_zoom + (mouse_wheel_down() - mouse_wheel_up()), 0);

x = dcos(direction) * dcos(cam_pitch) * cam_zoom;
y = -dsin(direction) * dcos(cam_pitch) * cam_zoom;
z = dsin(cam_pitch) * cam_zoom;

mouse_last_x = _mouse_x;
mouse_last_y = _mouse_y;