speed = 0;

camera.AspectRatio = window_get_width() / window_get_height();

var _mouseLeftPressed = mouse_check_button_pressed(mb_left);

if (!camera.MouseLook
	&& (_mouseLeftPressed || mouse_check_button(mb_right)))
{
	camera.set_mouselook(true);
	_mouseLeftPressed = false;
}
else if (keyboard_check_pressed(vk_escape))
{
	camera.set_mouselook(false);
}

window_set_cursor(camera.MouseLook ? cr_none : cr_arrow);

camera.update(delta_time);

if (camera.Position.Z < 0.0)
{
	camera.Position.Z = 0.0;
}

camera.update_matrices();

if (hasGun && camera.MouseLook && mouse_check_button_pressed(mb_right))
{
	aiming = !aiming;
}

var _chestIndex = 2;
var _neckIndex = 4;
var _rightArmIndex = 16;

if (GetCutscene())
{
}
else if (dead || pickingUp)
{
}
else if (shooting)
{
	direction = camera.Direction;
}
else if (aiming)
{
	direction = camera.Direction;
	if (_mouseLeftPressed)
	{
		shooting = true;
		var _sound = choose(
			SndGunshot0,
			SndGunshot1,
			SndGunshot2,
			SndGunshot3,
			SndGunshot4,
		);

		var _shellPos = matrix_transform_vertex(matrixGun, -0.1, 0, 0.2);

		var _shell = instance_create_depth(_shellPos[0], _shellPos[1], 0, OShell);
		_shell.z = _shellPos[2];
		_shell.direction = direction - 90;
		_shell.image_angle = direction;
		_shell.speed = random_range(0.2, 0.5);
		_shell.zspeed = random_range(0.5, 1.0);

		audio_play_sound_at(_sound, _shellPos[0], _shellPos[1], _shellPos[2], 150, 1000, 1, false, 1);

		var _origin = camera.Position;
		var _direction = camera.get_forward();
		var _hitId = noone;
		var _hitDist = infinity;

		with (OZombie)
		{
			if (!active || dead)
			{
				continue;
			}
			var _min = new BBMOD_Vec3(x - 5, y - 5, z);
			var _max = new BBMOD_Vec3(x + 5, y + 5, z + 36);
			var _dist = raycast_aabb(_origin, _direction, _min, _max);
			if (_dist != -1 && _dist < _hitDist)
			{
				_hitId = id;
				_hitDist = _dist;
			}
		}

		if (_hitId != noone)
		{
			_hitId.dead = true;
		}
	}
}
else
{
	if (z == 0)
	{
		if (keyboard_check_pressed(vk_space))
		{
			// Jump
			zspeed += 2;
		}
		else if (!hasGun
			&& keyboard_check_pressed(ord("E"))
			&& instance_exists(OGun))
		{
			// Pick up gun
			var _gun = instance_nearest(x, y, OGun);
			if (point_distance(x, y, _gun.x, _gun.y) < 20)
			{
				pickingUp = true;
			}
		}
	}

	var _moveX = keyboard_check(ord("W")) - keyboard_check(ord("S"));
	var _moveY = keyboard_check(ord("D")) - keyboard_check(ord("A"));

	if (_moveX != 0 || _moveY != 0)
	{
		direction = point_direction(0, 0, _moveX, _moveY) + camera.Direction;
		speed = !keyboard_check(vk_shift)
			? speedRun
			: speedWalk;
	}
}

////////////////////////////////////////////////////////////////////////////////
// Animation

// Control which animation to play
var _animation = OMain.animIdle;
var _animationLoop = true;

if (dead)
{
	// Dead
	_animation = OMain.animDeath;
	_animationLoop = false;
}
else if (shooting)
{
	_animation = OMain.animShoot;
	_animationLoop = false;
}
else if (aiming)
{
	_animation = OMain.animAim;
}
else if (pickingUp)
{
	// Interact
	_animation = OMain.animInteractGround;
	_animationLoop = false;
}
else if (z > 0)
{
	// Jump
	_animation = OMain.animJump;
}
else
{
	// Walk/run
	var _movedBy = speed;

	if (_movedBy >= speedRun)
	{
		_animation = OMain.animRun;
	}
	else if (_movedBy >= speedWalk)
	{
		_animation = OMain.animWalk;
	}
}

if (aiming || shooting)
{
	var _chestDq = animationPlayer.get_node_transform_from_frame(_chestIndex);
	var _chestRot = new BBMOD_Quaternion()
		.FromAxisAngle(new BBMOD_Vec3(1, 0, 0), -camera.DirectionUp * 0.25)
		.Mul(_chestDq.GetRotation());
	animationPlayer.set_node_rotation(_chestIndex, _chestRot);

	var _neckDq = animationPlayer.get_node_transform_from_frame(_neckIndex);
	var _neckRot = new BBMOD_Quaternion()
		.FromAxisAngle(new BBMOD_Vec3(1, 0, 0), -camera.DirectionUp * 0.25)
		.Mul(_neckDq.GetRotation());
	animationPlayer.set_node_rotation(_neckIndex, _neckRot);

	var _rightArmDq = animationPlayer.get_node_transform_from_frame(_rightArmIndex);
	var _rightArmRot = new BBMOD_Quaternion()
		.FromAxisAngle(new BBMOD_Vec3(0, 1, 0), camera.DirectionUp * 0.75)
		.Mul(_rightArmDq.GetRotation());
	animationPlayer.set_node_rotation(_rightArmIndex, _rightArmRot);
}
else
{
	animationPlayer.set_node_rotation(_chestIndex, undefined);
	animationPlayer.set_node_rotation(_neckIndex, undefined);
	animationPlayer.set_node_rotation(_rightArmIndex, undefined);
}

camera.Zoom = bbmod_lerp_delta_time(camera.Zoom, aiming ? 15 : 50, 0.2, delta_time);

// Play the animation
animationPlayer.change(_animation, _animationLoop);