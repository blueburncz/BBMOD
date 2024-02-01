// Show/hide debug overlay
if (keyboard_check_pressed(vk_f1))
{
	debugOverlay = !debugOverlay;
	show_debug_overlay(debugOverlay);
}

// Enable editing mode when the game is paused
renderer.EditMode = (global.gameSpeed == 0.0);

////////////////////////////////////////////////////////////////////////////////
// Spawn waves of zombies
waveTimeout -= DELTA_TIME * 0.000001;
if (!instance_exists(OZombie)
	|| waveTimeout <= 0)
{
	global.scoreBonus += max(ceil(waveTimeout), 0);

	repeat (++wave)
	{
		repeat (3)
		{
			var _randomX = OPlayer.x + random_range(-250, 250);
			var _randomY = OPlayer.y + random_range(-250, 250);
			if (global.terrain.in_bounds(_randomX, _randomY))
			{
				var _randomZ = global.terrain.get_height(_randomX, _randomY);
				instance_create_layer(
					_randomX,
					_randomY,
					"Instances",
					OZombie, { z: _randomZ });
				break;
			}
		}
	}

	// Give one zombie a gun
	with (OZombie)
	{
		dropGun = true;
		break;
	}

	waveTimeout = wave * 10;
}

////////////////////////////////////////////////////////////////////////////////
// Screen effects based on players health etc.
var _grayscale = (OPlayer.hp <= ceil(OPlayer.hpMax / 3.0)) ? 0.75 : 0.0;
monochrome.Strength = bbmod_lerp_delta_time(
	monochrome.Strength, _grayscale, 0.1, DELTA_TIME);

vignette.Strength = lerp(0.0, 1.5, OPlayer.hurt);

radialBlur.Strength = bbmod_lerp_delta_time(
	radialBlur.Strength, OPlayer.aiming ? 1.0 : 0.0, 0.1, DELTA_TIME);
