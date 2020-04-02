////////////////////////////////////////////////////////////////////////////////
// Camera control

var _mouse_x = window_mouse_get_x();
var _mouse_y = window_mouse_get_y();
var _mouse_sens = 1;

if (mouse_check_button(mb_right))
{
	direction += (mouse_last_x - _mouse_x) * _mouse_sens;
	cam_pitch -= (mouse_last_y - _mouse_y) * _mouse_sens;
	cam_pitch = clamp(cam_pitch, -89.99, 89.99);
}

var _speed = keyboard_check(vk_shift) ? 5 : 0.1;

cam_z += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * _speed;
cam_zoom = max(cam_zoom + (mouse_wheel_down() - mouse_wheel_up()) * _speed * 10, 0);

x = dcos(direction) * dcos(cam_pitch) * cam_zoom;
y = -dsin(direction) * dcos(cam_pitch) * cam_zoom;
z = cam_z + dsin(cam_pitch) * cam_zoom;

mouse_last_x = _mouse_x;
mouse_last_y = _mouse_y;

////////////////////////////////////////////////////////////////////////////////
// Play animations
var _anim_count = array_length_1d(animations);

if (keyboard_check_pressed(vk_left))
{
	if (--anim_current < 0)
	{
		anim_current = _anim_count - 1;
	}
}
else if (keyboard_check_pressed(vk_right))
{
	if (++anim_current >= _anim_count)
	{
		anim_current = 0;
	}
}

bbmod_animate(model, animations[anim_current], animation_instance);