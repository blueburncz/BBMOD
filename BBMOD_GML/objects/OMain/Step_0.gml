if (keyboard_check_pressed(vk_f1))
{
	debugOverlay = !debugOverlay;
	show_debug_overlay(debugOverlay);
}

////////////////////////////////////////////////////////////////////////////////
// Grayscale effect when zombies are near the player
var _grayscale = (OPlayer.hp < OPlayer.hpMax * 0.15) ? 0.75 : 0.0;

renderer.Grayscale = bbmod_lerp_delta_time(renderer.Grayscale, _grayscale, 0.01, delta_time);