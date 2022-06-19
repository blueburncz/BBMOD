# Changelog
Added new Particles module, using which you can create CPU particle effects.

Changed how light colors are passed to shaders, which enabled using their alpha
channels for the light intensity.

## GML API:
### Particles module:
* Added new module - Particles.

* Added new macro `BBMOD_VFORMAT_PARTICLE`.
* Added new macro `BBMOD_VFORMAT_PARTICLE_BATCHED`.
* Added new macro `BBMOD_SHADER_PARTICLE_UNLIT`.
* Added new macro `BBMOD_SHADER_PARTICLE_LIT`.
* Added new macro `BBMOD_SHADER_PARTICLE_DEPTH`.
* Added new macro `BBMOD_MATERIAL_PARTICLE_UNLIT`.
* Added new macro `BBMOD_MATERIAL_PARTICLE_LIT`.
* Added new macro `BBMOD_MODEL_PARTICLE`.

* Added new enum `BBMOD_EParticle`.

* Added new struct `BBMOD_ParticleEmitter`.
* Added new struct `BBMOD_ParticleModule`.
* Added new struct `BBMOD_ParticleSystem`.

* Added new struct `BBMOD_TerrainCollisionModule`.

* Added new struct `BBMOD_EmissionModule`.
* Added new struct `BBMOD_EmissionOverTimeModule`.
* Added new struct `BBMOD_MixEmissionModule`.

* Added new struct `BBMOD_AABBEmissionModule`.
* Added new struct `BBMOD_SphereEmissionModule`.

* Added new struct `BBMOD_CollisionEventModule`.

* Added new struct `BBMOD_CollisionKillModule`.

* Added new struct `BBMOD_AttractorModule`.
* Added new struct `BBMOD_DragModule`.
* Added new struct `BBMOD_GravityModule`.

* Added new struct `BBMOD_RandomRotationModule`.

* Added new struct `BBMOD_AddRealOnCollisionModule`.
* Added new struct `BBMOD_AddVec2OnCollisionModule`.
* Added new struct `BBMOD_AddVec3OnCollisionModule`.
* Added new struct `BBMOD_AddVec4OnCollisionModule`.

* Added new struct `BBMOD_AddRealOverTimeModule`.
* Added new struct `BBMOD_AddVec2OverTimeModule`.
* Added new struct `BBMOD_AddVec3OverTimeModule`.
* Added new struct `BBMOD_AddVec4OverTimeModule`.

* Added new struct `BBMOD_MixColorModule`.
* Added new struct `BBMOD_MixQuaternionModule`.
* Added new struct `BBMOD_MixRealModule`.
* Added new struct `BBMOD_MixVec2Module`.
* Added new struct `BBMOD_MixVec3Module`.
* Added new struct `BBMOD_MixVec4Module`.

* Added new struct `BBMOD_MixColorFromHealthModule`.
* Added new struct `BBMOD_MixQuaternionFromHealthModule`.
* Added new struct `BBMOD_MixRealFromHealthModule`.
* Added new struct `BBMOD_MixVec2FromHealthModule`.
* Added new struct `BBMOD_MixVec3FromHealthModule`.
* Added new struct `BBMOD_MixVec4FromHealthModule`.

* Added new struct `BBMOD_MixColorFromSpeedModule`.
* Added new struct `BBMOD_MixQuaternionFromSpeedModule`.
* Added new struct `BBMOD_MixRealFromSpeedModule`.
* Added new struct `BBMOD_MixVec2FromSpeedModule`.
* Added new struct `BBMOD_MixVec3FromSpeedModule`.
* Added new struct `BBMOD_MixVec4FromSpeedModule`.

* Added new struct `BBMOD_MixColorOverTimeModule`.
* Added new struct `BBMOD_MixQuaternionOverTimeModule`.
* Added new struct `BBMOD_MixRealOverTimeModule`.
* Added new struct `BBMOD_MixVec2OverTimeModule`.
* Added new struct `BBMOD_MixVec3OverTimeModule`.
* Added new struct `BBMOD_MixVec4OverTimeModule`.

* Added new struct `BBMOD_SetColorModule`.
* Added new struct `BBMOD_SetQuaternionModule`.
* Added new struct `BBMOD_SetRealModule`.
* Added new struct `BBMOD_SetVec2Module`.
* Added new struct `BBMOD_SetVec3Module`.
* Added new struct `BBMOD_SetVec4Module`.

* Added new struct `BBMOD_MixSpeedModule`.
