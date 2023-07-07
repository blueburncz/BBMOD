function DirtParticleSystem()
{
	static _particleSystem = undefined;
	if (!_particleSystem)
	{
		var _material = BBMOD_MATERIAL_PARTICLE_LIT.clone();
		_material.RenderQueue = new BBMOD_MeshRenderQueue("Dirt");
		_material.BaseOpacity = sprite_get_texture(SprDirtParticle, 0);
		_material.NormalSmoothness = sprite_get_texture(SprDirtParticle, 1);
		_material.SoftDistance = 2.0;
		_material.AlphaBlend = true;

		_particleSystem = new BBMOD_ParticleSystem(BBMOD_MODEL_PARTICLE, _material, 500)
			.add_modules(
				// Set particle color
				new BBMOD_SetColorModule(BBMOD_EParticle.ColorR, new BBMOD_Color(153, 140, 127)),
				// Rotate the particle randomly
				new BBMOD_RandomRotationModule(),
				// Make the particle move up on spawn
				new BBMOD_MixRealModule(BBMOD_EParticle.VelocityZ, 4),
				// Set random scale
				new BBMOD_MixVec3Module(BBMOD_EParticle.ScaleX,
					new BBMOD_Vec3(20.0),
					new BBMOD_Vec3(30.0)),
				// Decrease health over time
				new BBMOD_AddRealOverTimeModule(BBMOD_EParticle.HealthLeft, -1.0, 1.0),
				// Increase scale over time
				new BBMOD_AddVec3OverTimeModule(BBMOD_EParticle.ScaleX, new BBMOD_Vec3(2.0)),
				// Decrease alpha with health
				new BBMOD_MixRealFromHealthModule(BBMOD_EParticle.ColorA, 1.0, 0.0),
				// Apply gravity
				new BBMOD_GravityModule(),
			);
		_particleSystem.Loop = true;
		//_particleSystem.Sort = true;
	}
	return _particleSystem;
}
