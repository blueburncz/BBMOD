if (point_distance(x, y, OPlayer.x, OPlayer.y) < 50)
{
	if (keyboard_check_pressed(ord("E")))
	{
		state = !state;
		audio_play_sound_at(state ? SndSwitchOn : SndSwitchOff, x, y, z, 10, 300, 1, false, 1);
		if (OnChange != undefined)
		{
			OnChange(state);
		}
	}
}