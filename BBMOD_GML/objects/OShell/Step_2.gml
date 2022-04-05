event_inherited();

var _terrainHeight = OMain.terrain.get_height(x, y);

if (_terrainHeight != undefined
	&& z <= _terrainHeight
	&& !onGround)
{
	var _sound = choose(
		SndShell0,
		SndShell1,
		SndShell2,
		SndShell3,
		SndShell4,
		SndShell5,
		SndShell6,
		SndShell7,
	);
	audio_play_sound_at(_sound, x, y, z, 1, 100, 1, false, 1);

	onGround = true;
	alarm[0] = 600;
}

if (onGround)
{
	var _gameSpeed = game_get_speed(gamespeed_microseconds);
	var _deltaTime = DELTA_TIME / _gameSpeed;
	speedCurrent *= 1.0 - (0.05 * _deltaTime);
}