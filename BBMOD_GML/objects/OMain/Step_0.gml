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

var _locomotionForward = keyboard_check(vk_up) - keyboard_check(vk_down);
var _locomotionRight = keyboard_check(vk_right) - keyboard_check(vk_left);
var _locomotionSpeed = max(abs(_locomotionForward), abs(_locomotionRight));
if (keyboard_check(vk_shift))
{
	_locomotionSpeed *= 2.0;
}

if (keyboard_check(ord("1")))
{
	_locomotionSpeed = 0.0;
}
else if (keyboard_check(ord("2")))
{
	_locomotionSpeed = 1.0;
}
else if (keyboard_check(ord("3")))
{
	_locomotionSpeed = 2.0;
}

if (characterBurstRunHoldRemaining > 0)
{
	characterBurstRunHoldRemaining = max(0, characterBurstRunHoldRemaining - delta_time);
	_locomotionSpeed = max(_locomotionSpeed, 2.0);
}

var _deltaSecondsAnim = delta_time * 0.000001;
var _speedRate = (_locomotionSpeed > characterLocomotionSpeedCurrent)
	? characterLocomotionAccelRate
	: characterLocomotionDecelRate;
var _speedLerp = clamp(_deltaSecondsAnim * _speedRate, 0.0, 1.0);
characterLocomotionSpeedCurrent = lerp(characterLocomotionSpeedCurrent,
	_locomotionSpeed, _speedLerp);

if (keyboard_check_pressed(ord("R")))
{
	characterBurstRunHoldRemaining = characterBurstRunHoldDuration;
}

if (mouse_check_button_pressed(mb_left) && !characterIsShooting)
{
	characterIsShooting = true;
	characterPlayer.play(animCharacterShoot, false);
}

if (characterLocomotionSpeedCurrent > 1.5)
{
	characterDesiredAnimation = animCharacterRun;
}
else if (characterLocomotionSpeedCurrent > 0.1)
{
	characterDesiredAnimation = animCharacterWalk;
}
else
{
	characterDesiredAnimation = animCharacterIdle;
}
characterDesiredLoops = true;

if (!characterIsShooting)
{
	characterPlayer.change(characterDesiredAnimation, true);
}

characterPlayer.update(delta_time);

if (characterIsShooting && characterPlayer.Animation == undefined)
{
	characterIsShooting = false;
	characterPlayer.play(characterDesiredAnimation, characterDesiredLoops);
}

var _scale = 20.0;
directionalBlur.Vector.Set(
	angle_difference(camera.Direction, _directionPrev) * _scale,
	angle_difference(camera.DirectionUp, _directionUpPrev) * _scale);
var _length = directionalBlur.Vector.Length();
_length = (_length > 0.0) ? _length : 1.0;
directionalBlur.Step = 2.0 / min(_length, 32.0);
