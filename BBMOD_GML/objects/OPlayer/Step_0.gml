var _mouseLeftPressed = mouse_check_button_pressed(mb_left);

////////////////////////////////////////////////////////////////////////////////
// Update camera
camera.AspectRatio = window_get_width() / window_get_height();
camera.MouseSensitivity = aiming ? 0.25 : 1.0;

if (!camera.MouseLook && mouse_check_button(mb_any))
{
	camera.set_mouselook(true);
	// Consume the mouse press when just activating the mouselook.
	_mouseLeftPressed = false;
}
else if (keyboard_check_pressed(vk_escape))
{
	camera.set_mouselook(false);
}

window_set_cursor(camera.MouseLook ? cr_none : cr_default);

camera.Zoom = bbmod_lerp_delta_time(camera.Zoom, aiming ? zoomAim : zoomIdle, 0.2, delta_time);

camera.update(delta_time);

if (camera.Position.Z < 0.0)
{
	camera.Position.Z = 0.0;

	// We have to update the camera's matrices if we change its position or
	// target after we call its update method.
	camera.update_matrices();
}

// Increase camera exposure during nighttime
camera.Exposure = bbmod_lerp_delta_time(camera.Exposure, OSky.day ? 1.0 : 10.0, 0.025, delta_time);

////////////////////////////////////////////////////////////////////////////////
// Player controls
speed = 0;

if (!dead
	&& animationPlayer.Animation != OMain.animInteractGround)
{
	if (z == 0)
	{
		// Shooting
		if (hasGun
			&& camera.MouseLook
			&& mouse_check_button_pressed(mb_right))
		{
			aiming = !aiming;
		}

		if (aiming)
		{
			direction = camera.Direction;

			if (_mouseLeftPressed
				&& animationStateMachine.State == stateAim)
			{
				animationStateMachine.change_state(stateShoot);

				// Compute the position where a gun shell will be spawned
				var _shellPos = matrix_transform_vertex(matrixGun, -0.1, 0, 0.2);

				// Create a shell
				var _shell = instance_create_depth(_shellPos[0], _shellPos[1], 0, OShell);
				_shell.z = _shellPos[2];
				_shell.direction = direction - 90;
				_shell.image_angle = direction;
				_shell.speed = random_range(0.2, 0.5);
				_shell.zspeed = random_range(0.5, 1.0);

				// Play a rundom gunshot sound
				var _sound = choose(
					SndGunshot0,
					SndGunshot1,
					SndGunshot2,
					SndGunshot3,
					SndGunshot4,
				);

				audio_play_sound_at(_sound, _shellPos[0], _shellPos[1], _shellPos[2], 150, 1000, 1, false, 1);

				var _light = instance_create_depth(_shellPos[0], _shellPos[1], 0, OGunshotLight);
				_light.z = _shellPos[2];

				// Determine which enemy was shot using a raycast against an AABB at its position.
				var _origin = camera.Position;
				var _direction = camera.get_forward();
				var _hitId = noone;
				var _hitDist = infinity;

				with (OZombie)
				{
					if (dead)
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

		if (keyboard_check_pressed(vk_space))
		{
			// Jump
			zspeed += 2;
		}
		else if (!hasGun
			&& keyboard_check_pressed(ord("E"))
			&& instance_exists(OGun))
		{
			// Pick up a gun
			var _gun = instance_nearest(x, y, OGun);
			if (point_distance(x, y, _gun.x, _gun.y) < 20)
			{
				pickupTarget = _gun;
			}
		}
	}

	var _moveX = keyboard_check(ord("W")) - keyboard_check(ord("S"));
	var _moveY = keyboard_check(ord("D")) - keyboard_check(ord("A"));

	if (_moveX != 0 || _moveY != 0)
	{
		aiming = false;
		direction = point_direction(0, 0, _moveX, _moveY) + camera.Direction;
		speed = keyboard_check(vk_shift) ? speedWalk : speedRun;
	}
}

////////////////////////////////////////////////////////////////////////////////
// Control bones when the player is aiming
var _chestIndex = 2;
var _neckIndex = 4;
var _rightArmIndex = 16;

if (aiming)
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