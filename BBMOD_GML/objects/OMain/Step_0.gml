if (keyboard_check_pressed(vk_f1))
{
	debugOverlay = !debugOverlay;
	show_debug_overlay(debugOverlay);
}

////////////////////////////////////////////////////////////////////////////////
// Grayscale effect when zombies are near the player
var _playerX = OPlayer.x;
var _playerY = OPlayer.y;

var _grayscale = 0.0;
with (OZombie)
{
	if (!dead
		&& point_distance(x, y, _playerX, _playerY) < 100)
	{
		_grayscale = 0.75;
		break;
	}
}

renderer.Grayscale = bbmod_lerp_delta_time(renderer.Grayscale, _grayscale, 0.01, delta_time);