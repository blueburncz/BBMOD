event_inherited();

position = new BBMOD_Vec3(x, y, z);

emitter = new BBMOD_ParticleEmitter(position, GunfireParticleSystem());

light = new BBMOD_PointLight(BBMOD_C_ORANGE, position, 40);

bbmod_light_point_add(light);
