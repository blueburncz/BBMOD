event_inherited();

if (z <= 0 && !onGround)
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

	friction = 0.01;
	onGround = true;
	alarm[0] = 600;
}