light.Position = position.Add(new BBMOD_Vec3(0, 0, 18));
if (DELTA_TIME > 0)
{
	light.Color.Alpha = random_range(0.2, 0.3)
		* (emitter.ParticlesAlive / emitter.System.ParticleCount);
}
event_inherited();
