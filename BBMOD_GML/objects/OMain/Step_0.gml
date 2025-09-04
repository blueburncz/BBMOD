if (mouse_check_button_pressed(mb_right))
{
	camera.set_mouselook(true);
	window_set_cursor(cr_none);
}
else if (keyboard_check_pressed(vk_escape))
{
	camera.set_mouselook(false);
	window_set_cursor(cr_default);
}

var _moveSpeed = 0.5;
var _speed = (keyboard_check(vk_shift) ? 2 : 1) * _moveSpeed;
var _forward = (keyboard_check(ord("W")) - keyboard_check(ord("S"))) * _speed;
var _right = (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * _speed;
var _up = (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * _speed;

x += lengthdir_x(_forward, camera.Direction) + lengthdir_x(_right, camera.Direction - 90);
y += lengthdir_y(_forward, camera.Direction) + lengthdir_y(_right, camera.Direction - 90);
z += _up;

var _directionPrev = camera.Direction;
var _directionUpPrev = camera.DirectionUp;

renderer.update(delta_time);

camera.AspectRatio = surface_get_width(application_surface) / surface_get_height(application_surface);
camera.update(delta_time);

var _scale = 8.0;
directionalBlur.Vector.Set(
	angle_difference(camera.Direction, _directionPrev) * _scale,
	angle_difference(camera.DirectionUp, _directionUpPrev) * _scale);
var _length = directionalBlur.Vector.Length();
_length = (_length > 0.0) ? _length : 1.0;
directionalBlur.Step = 2.0 / min(_length, 32.0);
