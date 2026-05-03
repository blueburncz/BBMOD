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

if (keyboard_check_pressed(vk_f3))
{
	showRenderStatistics = !showRenderStatistics;
	show_debug_overlay(showRenderStatistics, false);
}

if (keyboard_check_pressed(vk_home))
{
	bbmod_dither_set_enabled(!bbmod_dither_get_enabled());
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
ditherFrustum.FromCamera(camera);

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

var _deltaSeconds = delta_time * 0.000001;

// Trigger-zone temporal dither for regular non-batched sample objects.
var i = 0;
repeat(array_length(ditherRegularStates))
{
	var _state = ditherRegularStates[i++];
	ditherDistanceScratch.Set(_state.X, _state.Y, _state.Z);
	var _distanceToCamera = abs(camera.get_distance(ditherDistanceScratch));

	if (_state.IsInside)
	{
		if (_distanceToCamera > ditherTriggerExitDistance)
		{
			_state.IsInside = false;
		}
	}
	else if (_distanceToCamera < ditherTriggerEnterDistance)
	{
		_state.IsInside = true;
	}

	var _targetFade = _state.IsInside ? 1.0 : 0.0;
	var _wasVisible = _state.WasVisible;
	var _isVisible = ditherFrustum.TestPoint(ditherDistanceScratch);
	_state.WasVisible = _isVisible;

	if (_isVisible && !_wasVisible)
	{
		_state.Fade = _targetFade;
	}
	else if (_targetFade > _state.Fade)
	{
		_state.Fade = min(1.0, _state.Fade + ditherFadeInRate * _deltaSeconds);
	}
	else if (_targetFade < _state.Fade)
	{
		_state.Fade = max(0.0, _state.Fade - ditherFadeOutRate * _deltaSeconds);
	}
}

batchSphereOrbitTime += _deltaSeconds;

i = 0;
repeat(array_length(batchSphereInstances))
{
	var _instance = batchSphereInstances[i++];
	var _angle = _instance.OrbitAngle + batchSphereOrbitTime * _instance.OrbitSpeed;
	var _radius = _instance.OrbitRadius;

	_instance.x = lengthdir_x(_radius, _angle);
	_instance.y = lengthdir_y(_radius, _angle);
	_instance.z = _instance.OrbitHeight + dsin(_angle * 2.0) * 0.75;
	_instance.image_angle = _angle;

	ditherDistanceScratch.Set(_instance.x, _instance.y, _instance.z);
	var _distanceToCamera = abs(camera.get_distance(ditherDistanceScratch));

	if (_instance.DitherInside)
	{
		if (_distanceToCamera > ditherTriggerExitDistance)
		{
			_instance.DitherInside = false;
		}
	}
	else if (_distanceToCamera < ditherTriggerEnterDistance)
	{
		_instance.DitherInside = true;
	}

	var _targetFade = _instance.DitherInside ? 1.0 : 0.0;
	var _instanceFade = _instance[$  BBMOD_DITHER_VALUE];
	var _wasVisible = _instance.DitherWasVisible;
	var _isVisible = ditherFrustum.TestPoint(ditherDistanceScratch);
	_instance.DitherWasVisible = _isVisible;

	if (_isVisible && !_wasVisible)
	{
		_instanceFade = _targetFade;
	}
	else if (_targetFade > _instanceFade)
	{
		_instanceFade = min(1.0, _instanceFade + ditherFadeInRate * _deltaSeconds);
	}
	else if (_targetFade < _instanceFade)
	{
		_instanceFade = max(0.0, _instanceFade - ditherFadeOutRate * _deltaSeconds);
	}
	_instance[$  BBMOD_DITHER_VALUE] = _instanceFade;

	batchSphere.update_instance(_instance);
}

i = 0;
repeat(array_length(punctualLightsTest))
{
	var _light = punctualLightsTest[i++];
	var _angle = _light[$ "OrbitAngle"] + batchSphereOrbitTime * _light[$ "OrbitSpeed"];
	var _radius = _light[$ "OrbitRadius"];
	var _height = _light[$ "OrbitHeight"];

	_light.Position.Set(
		lengthdir_x(_radius, _angle),
		lengthdir_y(_radius, _angle),
		_height + dsin(_angle * 1.5) * 1.5
	);
}

if (spotLightTest != undefined)
{
	var _spotAngle = spotLightTest[$ "OrbitAngle"] + batchSphereOrbitTime * spotLightTest[$ "OrbitSpeed"];
	var _spotRadius = spotLightTest[$ "OrbitRadius"];
	var _spotHeight = spotLightTest[$ "OrbitHeight"];

	spotLightTest.Position.Set(
		lengthdir_x(_spotRadius, _spotAngle),
		lengthdir_y(_spotRadius, _spotAngle),
		_spotHeight
	);

	var _toCenter = new BBMOD_Vec3(
		-spotLightTest.Position.X,
		-spotLightTest.Position.Y,
		2.0 - spotLightTest.Position.Z
	).Normalize();

	spotLightTest.Direction.Set(_toCenter.X, _toCenter.Y, _toCenter.Z);
}

////////////////////////////////////////////////////////////////////////////////
//
// Particle module showcase
//
if (particleModuleShowcaseEnabled)
{
	i = 0;
	repeat(array_length(particleModuleShowcaseEmitters))
	{
		particleModuleShowcaseEmitters[i++].update(delta_time);
	}
}
