/// @func DissolveParticleSystem()
///
/// @desc
///
/// @return {Struct.BBMOD_ParticleSystem}
function DissolveParticleSystem()
{
	static _particleSystem = undefined;
	if (!_particleSystem)
	{
		var _material = BBMOD_MATERIAL_PARTICLE_UNLIT.clone();
		_material.RenderQueue = new BBMOD_RenderQueue("Dissolve");

		_particleSystem = new BBMOD_ParticleSystem(BBMOD_MODEL_PARTICLE, _material, 100)
			.add_modules(
				// Emit 20 particles every 0.05 seconds
				new BBMOD_EmissionOverTimeModule(20, 0.05),
				// Emit particles in an AABB shape
				new BBMOD_AABBEmissionModule(
					new BBMOD_Vec3(-5.0, -5.0, 0.0),
					new BBMOD_Vec3(5.0, 5.0, 36.0)),
				// Set random particle direction
				new BBMOD_MixRealModule(BBMOD_EParticle.VelocityX, -1, 1),
				new BBMOD_MixRealModule(BBMOD_EParticle.VelocityY, -1, 1),
				new BBMOD_MixRealModule(BBMOD_EParticle.VelocityZ, -1, 1),
				// Set particle speed to 10
				new BBMOD_MixSpeedModule(10.0),
				// Set partile color to green whey the are spawned
				new BBMOD_SetColorModule(BBMOD_EParticle.ColorR, new BBMOD_Color(0, 255 * 2, 127 * 2)),
				// Decrease particle health over time
				new BBMOD_AddRealOverTimeModule(BBMOD_EParticle.HealthLeft, -1.0, 1.0),
				// Scale particles based on their health
				new BBMOD_MixVec3FromHealthModule(BBMOD_EParticle.ScaleX,
					new BBMOD_Vec3(1.0), new BBMOD_Vec3(0.0)),
				// Move particles upwards
				new BBMOD_GravityModule(new BBMOD_Vec3(10.0, 10.0, 20.0)),
			);
		// Emit particles for 0.5 seconds
		_particleSystem.Duration = 0.5;
	}
	return _particleSystem;
}
