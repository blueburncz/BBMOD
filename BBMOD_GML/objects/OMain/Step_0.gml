// Show/hide debug overlay
if (keyboard_check_pressed(vk_f1))
{
	debugOverlay = !debugOverlay;
	show_debug_overlay(debugOverlay);
}

// Enable/disable edit mode
if (keyboard_check_pressed(vk_f2))
{
	global.editMode = !global.editMode;
}

gizmo.Visible = global.editMode;

////////////////////////////////////////////////////////////////////////////////
// Spawn waves of zombies
waveTimeout -= DELTA_TIME * 0.000001;
if (!instance_exists(OZombie)
	|| waveTimeout <= 0)
{
	global.scoreBonus += max(ceil(waveTimeout), 0);

	repeat (++wave)
	{
		var _randomPosition = global.terrain.get_random_position();
		instance_create_layer(
			_randomPosition.X,
			_randomPosition.Y,
			"Instances",
			OZombie);
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
renderer.Grayscale = bbmod_lerp_delta_time(renderer.Grayscale, _grayscale, 0.1, DELTA_TIME);

var _hurt = OPlayer.hurt;
renderer.Vignette = lerp(0.8, 1.5, _hurt);
renderer.VignetteColor = merge_color(c_black, c_red, _hurt);

////////////////////////////////////////////////////////////////////////////////
// Particles
particleEmitter.update(DELTA_TIME);
if (DELTA_TIME > 0.0)
{
	var _factor = random(1.0);
	emitterLight.Color = BBMOD_C_BLACK.Mix(BBMOD_C_ORANGE, lerp(0.5, 0.6, _factor));
	emitterLight.Range = lerp(29.0, 31.0, _factor);
}
