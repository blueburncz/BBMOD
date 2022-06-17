event_inherited();

life -= DELTA_TIME * 0.001;
if (life <= 0.0)
{
	instance_destroy();
}
