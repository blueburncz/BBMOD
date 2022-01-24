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
	scoreBonus += max(ceil(waveTimeout), 0);
	repeat (++wave)
	{
		instance_create_layer(
			random(room_width),
			random(room_height),
			"Instances",
			OZombie);
	}
	with (OZombie)
	{
		dropGun = true;
		break;
	}
	waveTimeout = min(wave * 5, 60);
}

////////////////////////////////////////////////////////////////////////////////
// Screen effects based on players health etc.
var _grayscale = (OPlayer.hp < OPlayer.hpMax * 0.25) ? 0.75 : 0.0;
renderer.Grayscale = bbmod_lerp_delta_time(renderer.Grayscale, _grayscale, 0.1, DELTA_TIME);

var _hurt = OPlayer.hurt;
renderer.Vignette = lerp(0.8, 1.5, _hurt);
renderer.VignetteColor = merge_color(c_black, c_red, _hurt);