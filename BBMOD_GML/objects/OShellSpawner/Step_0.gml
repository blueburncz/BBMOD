if (point_distance(x, y, OPlayer.x, OPlayer.y) < 100)
{
	timeout -= delta_time * 0.001;
	if (timeout <= 0.0)
	{
		with (instance_create_depth(x, y, 0, OShell))
		{
			z = 30;
			image_angle = random(360);
			direction = random(360);
			speed = random_range(0.2, 0.5);
			zspeed = random_range(0.5, 1.0);
		}
		timeout = random_range(1000, 3000);
	}
}