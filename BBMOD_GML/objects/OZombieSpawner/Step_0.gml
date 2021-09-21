if (active)
{
	timeout -= delta_time * 0.001;
	if (timeout <= 0)
	{
		instance_create_depth(x, y, 0, OZombie);
		instance_destroy();
	}
}