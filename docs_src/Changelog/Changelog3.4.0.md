# Changelog

- Removed deprecated and obsolete API!
- New "Particles" module.
- Cleaned up shaders.

## GML API:
### General:
* Further fixes of variable and argument types in docs.
* Removed all API previously marked as deprecated or obsolete!

### Core module:
* Added new property `ShadowmapBias` to `BBMOD_DefaultMaterial`.
* Fixed method `Mul` of `BBMOD_Matrix`.

### Particles module:
* Added new module - Particles.
* Added new enum `BBMOD_EParticle`, which describes particle properties.
* Added new struct `BBMOD_ParticleModule`, which is a base struct for particle modules. Particle modules operate on particle properties to define their look and behavior.
* Added new struct `BBMOD_ParticleSystem`, which contains a mesh, material, list of particle modules and other properties that together define the look and behavior of a single particle type.
* Added new struct `BBMOD_ParticleEmitter`, which is used to emit particles of a specific type at its position in the world.
* Added new macro `BBMOD_VFORMAT_PARTICLE`, which is a vertex format of a single billboard particle.
* Added new macro `BBMOD_VFORMAT_PARTICLE_BATCHED`, which is a vertex format of dynamic batch of billboard particles.
* Added new macro `BBMOD_SHADER_PARTICLE_UNLIT`, which is a shader for rendering dynamic batches of unlit billboard particles.
* Added new macro `BBMOD_SHADER_PARTICLE_LIT`, which is a shader for rendering dynamic batches of lit billboard particles.
* Added new macro `BBMOD_SHADER_PARTICLE_DEPTH`, which is a shader for rendering dynamic batches of billboard particles into depth buffers.
* Added new macro `BBMOD_MATERIAL_PARTICLE_UNLIT`, which is the default material for rendering dynamic batches of unlit billboard particles.
* Added new macro `BBMOD_MATERIAL_PARTICLE_LIT`, which is the default material for rendering dynamic batches of lit billboard particles. This material uses `BBMOD_SHADER_PARTICLE_DEPTH` for the shadow rendering pass.
* Added new macro `BBMOD_MODEL_PARTICLE`, which is a billboard particle model.

* Added new struct `BBMOD_InitialBounceModule`.

* Added new struct `BBMOD_TerrainCollisionModule`.

* Added new struct `BBMOD_ColorFromHealthModule`.
* Added new struct `BBMOD_ColorFromSpeedModule`.
* Added new struct `BBMOD_InitialColorModule`.
* Added new struct `BBMOD_MixInitialColorModule`.

* Added new struct `BBMOD_InitialDragModule`.

* Added new struct `BBMOD_AABBEmissionModule`.
* Added new struct `BBMOD_EmissionOverTimeModule`.
* Added new struct `BBMOD_InitialEmissionModule`.
* Added new struct `BBMOD_MixInitialEmissionModule`.
* Added new struct `BBMOD_SphereEmissionModule`.

* Added new struct `BBMOD_CollisionEventModule`.

* Added new struct `BBMOD_AddHealthOnCollisionModule`.
* Added new struct `BBMOD_AddHealthOverTimeModule`.
* Added new struct `BBMOD_InitialHealthModule`.
* Added new struct `BBMOD_MixInitialHealthModule`.

* Added new struct `BBMOD_AABBKillModule`.
* Added new struct `BBMOD_AlphaKillModule`.
* Added new struct `BBMOD_CollisionKillModule`.
* Added new struct `BBMOD_HeightKillModule`.
* Added new struct `BBMOD_ScaleKillModule`.
* Added new struct `BBMOD_SpeedKillModule`.
* Added new struct `BBMOD_SphereKillModule`.

* Added new struct `BBMOD_InitialMassModule`.

* Added new struct `BBMOD_AttractorModule`.
* Added new struct `BBMOD_DragModule`.
* Added new struct `BBMOD_GravityModule`.

* Added new struct `BBMOD_AddScaleOverTimeModule`.
* Added new struct `BBMOD_InitialScaleModule`.
* Added new struct `BBMOD_MixInitialScaleModule`.
* Added new struct `BBMOD_ScaleFromHealthModule`.
* Added new struct `BBMOD_ScaleFromSpeedModule`.

* Added new struct `BBMOD_InitialVelocityModule`.
* Added new struct `BBMOD_MixInitialVelocityModule`.
