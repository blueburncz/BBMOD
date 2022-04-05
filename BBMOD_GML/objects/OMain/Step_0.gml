// Show/hide debug overlay
if (keyboard_check_pressed(vk_f1))
{
	debugOverlay = !debugOverlay;
	show_debug_overlay(debugOverlay);
}

////////////////////////////////////////////////////////////////////////////////
// Spawn waves of zombies
waveTimeout -= DELTA_TIME * 0.000001;
if (!instance_exists(OZombie)
	|| waveTimeout <= 0)
{
	global.scoreBonus += max(ceil(waveTimeout), 0);

	repeat (++wave)
	{
		instance_create_layer(
			terrain.Position.X + random(terrain.Size.X),
			terrain.Position.Y + random(terrain.Size.Y),
			"Instances",
			OZombie);
	}

	// Give one zombie a gun
	with (OZombie)
	{
		dropGun = true;
		break;
	}

	waveTimeout = wave * 5;
}

////////////////////////////////////////////////////////////////////////////////
// Screen effects based on players health etc.
var _grayscale = (OPlayer.hp <= ceil(OPlayer.hpMax / 3.0)) ? 0.75 : 0.0;
renderer.Grayscale = bbmod_lerp_delta_time(renderer.Grayscale, _grayscale, 0.1, DELTA_TIME);

var _hurt = OPlayer.hurt;
renderer.Vignette = lerp(0.8, 1.5, _hurt);
renderer.VignetteColor = merge_color(c_black, c_red, _hurt);