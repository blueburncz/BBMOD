if (hp <= 0)
{
	dissolve += delta_time * 0.000001;
	if (dissolve >= 1.0)
	{
		destroy = true;
	}
}