if (mouse_check_button(mb_right))
{
	camera.set_mouselook(true);
	window_set_cursor(cr_none);
}
else
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

camera.update(delta_time);

renderer.update(delta_time);
