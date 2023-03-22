function GunfireParticleSystem()
{
	static _particleSystem = undefined;
	if (!_particleSystem)
	{
		var _material = BBMOD_MATERIAL_PARTICLE_UNLIT.clone();
		_material.RenderQueue = new BBMOD_RenderQueue("Gunfire");
		_material.BaseOpacity = sprite_get_texture(SprGunfire, 0);
		_material.BlendMode = bm_add;

		_particleSystem = new BBMOD_ParticleSystem(BBMOD_MODEL_PARTICLE, _material, 10)
			.add_modules(
				// Emit particles at start
				new BBMOD_EmissionModule(10),
				// Set particle color
				new BBMOD_MixColorModule(BBMOD_EParticle.ColorR, BBMOD_C_RED, BBMOD_C_YELLOW),
				// Rotate the particle randomly
				new BBMOD_RandomRotationModule(),
				// Set random scale
				new BBMOD_MixVec3Module(BBMOD_EParticle.ScaleX,
					new BBMOD_Vec3(3.0),
					new BBMOD_Vec3(8.0)),
				// Decrease health over time
				new BBMOD_AddRealOverTimeModule(BBMOD_EParticle.HealthLeft, -1.0, 0.1),
				// Decrease alpha with health
				new BBMOD_MixRealFromHealthModule(BBMOD_EParticle.ColorA, 1.0, 0.0),
			);
		_particleSystem.Duration = 0.1;
	}
	return _particleSystem;
}
