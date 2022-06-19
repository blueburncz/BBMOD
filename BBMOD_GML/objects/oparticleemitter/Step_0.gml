if (emitter)
{
	emitter.Position.Set(x, y, z);

	if (DELTA_TIME > 0.0)
	{
		emitter.update(DELTA_TIME);
	}
	if (emitter.finished(true))
	{
		instance_destroy();
	}
}
