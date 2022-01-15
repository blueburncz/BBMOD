timeout -= delta_time * 0.000001;
if (timeout <= 0)
{
	SetSky(!day);
	timeout = 30;
}