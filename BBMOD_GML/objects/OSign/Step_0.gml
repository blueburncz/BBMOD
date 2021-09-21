if (point_distance(x, y, OPlayer.x, OPlayer.y) < 50)
{
	if (cutscene && keyboard_check_pressed(ord("E")))
	{
		if (!GetCutscene())
		{
			cutscene.Start();
		}
		else if (cutscene.Active)
		{
			cutscene.Next();
		}
	}
}