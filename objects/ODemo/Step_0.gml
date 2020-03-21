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

cam_z += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * 0.1;
cam_zoom = max(cam_zoom + (mouse_wheel_down() - mouse_wheel_up()), 0);

x = dcos(direction) * dcos(cam_pitch) * cam_zoom;
y = -dsin(direction) * dcos(cam_pitch) * cam_zoom;
z = cam_z + dsin(cam_pitch) * cam_zoom;

mouse_last_x = _mouse_x;
mouse_last_y = _mouse_y;

////////////////////////////////////////////////////////////////////////////////
// Play animations

if (model != B_BBMOD_NONE)
{
	var _anim_name = ds_map_find_first(model[@ B_EBBMOD.Animations]);
	if (is_undefined(transform))
	{
		transform = b_bbmod_create_transform_array(model);
	}
	b_bbmod_animate(model, _anim_name, transform);
}