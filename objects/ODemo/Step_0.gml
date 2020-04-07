////////////////////////////////////////////////////////////////////////////////
// Control character
var _anim_prev = anim_current;
var _anim_loop = false;

if (anim_current != anim_reload)
{
	anim_current = anim_idle;
	_anim_loop = true;

	if (keyboard_check(ord("A")))
	{
		anim_current = anim_strafe_left;
		_anim_loop = true;
	}
	else if (keyboard_check(ord("D")))
	{
		anim_current = anim_strafe_right;
		_anim_loop = true;
	}

	if (keyboard_check(ord("W")))
	{
		anim_current = anim_walk_forward;
		_anim_loop = true;
	}
	else if (keyboard_check(ord("S")))
	{
		anim_current = anim_walk_backward;
		_anim_loop = true;
	}

	if (keyboard_check_pressed(ord("R")))
	{
		anim_current = anim_reload;
		_anim_loop = false;
	}

	if (mouse_check_button(mb_left))
	{
		anim_current = anim_firing;
		_anim_loop = false;
	}
}

if (_anim_prev != anim_current)
{
	bbmod_play(animation_player, anim_current, _anim_loop);
}

////////////////////////////////////////////////////////////////////////////////
// Play animations
if (!bbmod_animation_player_update(animation_player, current_time * 0.001))
{
	anim_current = anim_idle;
	bbmod_play(animation_player, anim_current, true);
}

////////////////////////////////////////////////////////////////////////////////
// Control camera
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