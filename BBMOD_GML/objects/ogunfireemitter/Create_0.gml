event_inherited();

position = new BBMOD_Vec3(x, y, z);

emitter = new BBMOD_ParticleEmitter(position, GunfireParticleSystem());

light = new BBMOD_PointLight(BBMOD_C_ORANGE, position, random_range(70, 80));
light.RenderPass = ~(1 << BBMOD_ERenderPass.ReflectionCapture);
light.Color.Alpha = random_range(2.5, 3);

bbmod_light_punctual_add(light);
