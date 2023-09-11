var _mouseLeftPressed = mouse_check_button_pressed(mb_left);

////////////////////////////////////////////////////////////////////////////////
// Update camera
camera.AspectRatio = window_get_width() / window_get_height();
camera.MouseSensitivity = aiming ? 0.25 : 1.0;

if (!camera.MouseLook && mouse_check_button(mb_left))
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

global.gameSpeed = camera.MouseLook ? 1.0 : 0.0;

camera.Zoom = bbmod_lerp_delta_time(camera.Zoom, aiming ? zoomAim : zoomIdle, 0.2, DELTA_TIME);

camera.update(DELTA_TIME);

var _cameraHeight = (global.terrain.get_height(camera.Position.X, camera.Position.Y) ?? 0.0) + 1.0;
if (camera.Position.Z < _cameraHeight)
{
	camera.Position.Z = _cameraHeight;

	// We have to update the camera's matrices if we change its position or
	// target after we call its update method.
	camera.update_matrices();
}

// Increase camera exposure during nighttime
camera.Exposure = bbmod_lerp_delta_time(camera.Exposure, global.day ? 1.0 : 2.0, 0.05, delta_time);

////////////////////////////////////////////////////////////////////////////////
// Player controls
if (global.gameSpeed > 0.0)
{
	var _gameSpeed = game_get_speed(gamespeed_microseconds);
	var _deltaTime = DELTA_TIME / _gameSpeed;
	speedCurrent *= 1.0 - (0.1 * _deltaTime);

	if (global.terrain.in_bounds(x, y)
		&& animationPlayer.Animation != animInteractGround)
	{
		var _terrainHeight = global.terrain.get_height(x, y);

		if (_terrainHeight != undefined
			&& z >= _terrainHeight
			&& z < _terrainHeight + 5.0)
		{
			// Shooting
			if (ammo > 0
				&& camera.MouseLook
				&& mouse_check_button_pressed(mb_right))
			{
				aiming = !aiming;
			}

			if (aiming)
			{
				direction = camera.Direction;

				if (_mouseLeftPressed
					/*&& animationStateMachine.State == stateAim*/)
				{
					animationStateMachine.change_state(stateShoot);

					// Compute the position where a gun shell will be spawned
					var _shellPos = matrix_transform_vertex(matrixGun, -0.1, 0, 0.2);

					// Create a shell
					var _shell = instance_create_layer(_shellPos[0], _shellPos[1], layer, OShell);
					_shell.z = _shellPos[2];
					_shell.direction = direction - 90;
					_shell.image_angle = direction;
					_shell.speedCurrent = random_range(0.2, 0.5);
					_shell.zspeed = random_range(0.5, 1.0);

					// Play a rundom gunshot sound
					var _gunfirePosition = matrix_transform_vertex(matrixGun, -0.5, 0, 0.2);

					var _sound = choose(
						SndGunshot0,
						SndGunshot1,
						SndGunshot2,
						SndGunshot3,
						SndGunshot4,
					);
					audio_play_sound_at(_sound, _gunfirePosition[0], _gunfirePosition[1], _gunfirePosition[2], 150, 1000, 1, false, 1);

					// Spawn gunfire emitter
					var _emitter = instance_create_layer(_gunfirePosition[0], _gunfirePosition[1], layer, OGunfireEmitter);
					_emitter.z = _gunfirePosition[2];

					// Determine which enemy was shot using a raycast against an AABB at its position.
					var _ray = new BBMOD_Ray(camera.Position, camera.get_forward());

					with (OZombie)
					{
						if (hp <= 0)
						{
							continue;
						}

						if (collider.Raycast(_ray))
						{
							ReceiveDamage(irandom_range(45, 55));

							knockback = new BBMOD_Vec3(
								lengthdir_x(5, other.camera.Direction),
								lengthdir_y(5, other.camera.Direction),
								0);

							var _index = audio_play_sound_at(
								choose(SndZombie0, SndZombie1),
								x,
								y,
								z + 30,
								10, 1000, 1, false, 1);
							audio_sound_pitch(_index, random_range(1.0, 1.5));
						}
					}

					if (--ammo == 0)
					{
						aiming = false;
					}
				}
			}
			else if (_mouseLeftPressed
				&& ((animationStateMachine.State != statePunchRight
				&& animationStateMachine.State != statePunchLeft)
				|| chainPunch))
			{
				// Punch
				animationStateMachine.change_state(punchRight ? statePunchRight : statePunchLeft);
				punchRight = !punchRight;
				chainPunch = false;
				speedCurrent = 2;

				var _hit = false;
				var _zombie = instance_nearest(x, y, OZombie);
				if (_zombie != noone)
				{
					var _dist = point_distance(x, y, _zombie.x, _zombie.y);
					if (_dist < 30)
					{
						if (_dist < 25)
						{
							speedCurrent = 1;
						}

						if (_dist > 10)
						{
							direction = point_direction(x, y, _zombie.x, _zombie.y);
						}

						_zombie.ReceiveDamage(irandom_range(15, 20));

						_zombie.knockback = new BBMOD_Vec3(
							lengthdir_x(2, direction),
							lengthdir_y(2, direction),
							0);

						var _index = audio_play_sound_at(
							SndPunch,
							x + lengthdir_x(30, direction),
							y + lengthdir_y(30, direction),
							z + 30,
							10, 200, 1, false, 1);
						audio_sound_pitch(_index, random_range(0.75, 1));

						_hit = true;
					}
				}

				if (!_hit)
				{
					var _index = audio_play_sound_at(
						SndWhoosh,
						x + lengthdir_x(30, direction),
						y + lengthdir_y(30, direction),
						z + 30,
						10, 200, 1, false, 1);
					audio_sound_pitch(_index, random_range(0.75, 1));
				}
			}

			if (keyboard_check_pressed(vk_space))
			{
				// Jump
				zspeed += 2;
				aiming = false;
			}
			else if (keyboard_check_pressed(ord("E"))
				&& instance_exists(OItem))
			{
				// Pick up an item
				var _item = instance_nearest(x, y, OItem);
				if (point_distance(x, y, _item.x, _item.y) < _item.pickupRange)
				{
					pickupTarget = _item;
				}
			}
		}

		var _moveX = keyboard_check(ord("W")) - keyboard_check(ord("S"));
		var _moveY = keyboard_check(ord("D")) - keyboard_check(ord("A"));

		if ((_moveX != 0 || _moveY != 0)
			&& (animationStateMachine.State != statePunchLeft
			&& animationStateMachine.State != statePunchRight))
		{
			aiming = false;
			direction = point_direction(0, 0, _moveX, _moveY) + camera.Direction;
			speedCurrent = keyboard_check(vk_shift) ? speedWalk : speedRun;
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
// Control bones when the player is aiming
var _chestIndex = 2;
var _neckIndex = 4;
var _rightArmIndex = 16;

if (aiming)
{
	var _chestRot = (new BBMOD_Quaternion())
		.FromAxisAngle(new BBMOD_Vec3(1, 0, 0), -camera.DirectionUp * 0.25);
	animationPlayer.set_node_rotation_post(_chestIndex, _chestRot);

	var _neckRot = (new BBMOD_Quaternion())
		.FromAxisAngle(new BBMOD_Vec3(1, 0, 0), -camera.DirectionUp * 0.25);
	animationPlayer.set_node_rotation_post(_neckIndex, _neckRot);

	var _rightArmRot = (new BBMOD_Quaternion())
		.FromAxisAngle(new BBMOD_Vec3(0, 1, 0), camera.DirectionUp * 0.75);
	animationPlayer.set_node_rotation_post(_rightArmIndex, _rightArmRot);
}
else
{
	animationPlayer.set_node_rotation_post(_chestIndex, undefined);
	animationPlayer.set_node_rotation_post(_neckIndex, undefined);
	animationPlayer.set_node_rotation_post(_rightArmIndex, undefined);
}

////////////////////////////////////////////////////////////////////////////////
// Game over
if (hp <= 0.0)
{
	room_goto(RmGameOver);
}

////////////////////////////////////////////////////////////////////////////////
// Test: Create shadow casting point lights

//if (keyboard_check_pressed(vk_enter))
//{
//	var _light = new BBMOD_PointLight();
//	_light.Color = new BBMOD_Color().FromHSV(
//		random(255),
//		255,
//		255
//	);
//	_light.Color.Alpha = 0.5;
//	_light.Position = new BBMOD_Vec3(x, y, z + 30);
//	_light.Range = random_range(50, 100);
//	_light.CastShadows = true;
//	bbmod_light_punctual_add(_light);
//}
