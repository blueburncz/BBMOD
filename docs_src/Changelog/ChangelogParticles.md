# Changelog
Added new Particles module, using which you can create CPU particle effects.

Changed how light colors are passed to shaders, which enabled using their alpha
channels for the light intensity.

## GML API:
### Particles module:
* Added new module - Particles.
* Added new macro `BBMOD_VFORMAT_PARTICLE`, which is a vertex format of a single billboard particle.
* Added new macro `BBMOD_VFORMAT_PARTICLE_BATCHED`, which is a vertex format of dynamic batch of billboard particles.
* Added new macro `BBMOD_MODEL_PARTICLE`, which is a billboard particle model.
* Added new macro `BBMOD_SHADER_PARTICLE_UNLIT`, which is a shader for rendering dynamic batches of unlit billboard particles.
* Added new macro `BBMOD_SHADER_PARTICLE_LIT`, which is a shader for rendering dynamic batches of lit billboard particles.
* Added new macro `BBMOD_SHADER_PARTICLE_DEPTH`, which is a shader for rendering dynamic batches of billboard particles into depth buffers.
* Added new macro `BBMOD_MATERIAL_PARTICLE_UNLIT`, which is the default material for rendering dynamic batches of unlit billboard particles.
* Added new macro `BBMOD_MATERIAL_PARTICLE_LIT`, which is the default material for rendering dynamic batches of lit billboard particles.
* Added new enum `BBMOD_EParticle`, which is an enumeration of particle properties.
* Added new struct `BBMOD_ParticleModule`, which is a base struct for particle modules. These are composed into particle system to define behavior of their particles.
* Added new struct `BBMOD_ParticleSystem`, which is a collection of particle modules that together define behavior of particles.
* Added new struct `BBMOD_ParticleEmitter`, which emits particles at a specific position in the world. The behavior of the emitted particles is defined by a particle system.
* Added new struct `BBMOD_ParticleShader`, which is a shader used by particle materials.
* Added new struct `BBMOD_ParticleMaterial`, which is a material that can be used for rendering particles.
* Added new struct `BBMOD_EmissionModule`, which is a particle module that spawns particles at the start of a particle emitter's life.
* Added new struct `BBMOD_EmissionOverTimeModule`, which is a particle module that emits particles over time.
* Added new struct `BBMOD_MixEmissionModule`, which is a particle module that spawns random number of particles at the start of a particle emitter's life.
* Added new struct `BBMOD_AABBEmissionModule`, which is a particle module that positions spawned particles into an AABB shape.
* Added new struct `BBMOD_SphereEmissionModule`, which is a particle module that positions spawned particles into a sphere shape.
* Added new struct `BBMOD_RandomRotationModule`, which is a particle module that randomly sets particles' rotation on their spawn.
* Added new struct `BBMOD_MixSpeedModule`, which is a particle module that randomly sets initial magnitude of particles' velocity vector.
* Added new struct `BBMOD_SetColorModule`, which is a universal particle module that sets initial value of particles' color property when they are spawned.
* Added new struct `BBMOD_SetQuaternionModule`, which is a universal particle module that sets initial value of particles' quaternion property when they are spawned.
* Added new struct `BBMOD_SetRealModule`, which is a universal particle module that sets initial value of particles' property when they are spawned.
* Added new struct `BBMOD_SetVec2Module`, which is a universal particle module that sets initial value of two consecutive particle properties when it is spawned.
* Added new struct `BBMOD_SetVec3Module`, which is a universal particle module that sets initial value of three consecutive particle properties when it is spawned.
* Added new struct `BBMOD_SetVec4Module`, which is a universal particle module that sets initial value of four consecutive particle properties when it is spawned.
* Added new struct `BBMOD_MixColorModule`, which is a universal particle module that randomly mixes particles' color property when they are spawned.
* Added new struct `BBMOD_MixQuaternionModule`, which is a universal particle module that randomly mixes particles' quaternion property when they are spawned.
* Added new struct `BBMOD_MixRealModule`, which is a universal particle module that randomly mixes initial value of particles' property between two values when they are spawned.
* Added new struct `BBMOD_MixVec2Module`, which is a universal particle module that randomly mixes initial values of particles' two consecutive properties between two values when they are spawned.
* Added new struct `BBMOD_MixVec3Module`, which is a universal particle module that randomly mixes initial values of particles' three consecutive properties between two values when they are spawned.
* Added new struct `BBMOD_MixVec4Module`, which is a universal particle module that randomly mixes initial values of particles' four consecutive properties between two values  when they are spawned.
* Added new struct `BBMOD_MixColorOverTimeModule`, which is a universal particle module that mixes particles' color property between two values based on their time alive.
* Added new struct `BBMOD_MixQuaternionOverTimeModule`, which is a universal particle module that mixes particles' quaternion property between two values based on their time alive.
* Added new struct `BBMOD_MixRealOverTimeModule`, which is a universal particle module that mixes value of particles' property between two values based on their time alive.
* Added new struct `BBMOD_MixVec2OverTimeModule`, which is a universal particle module that mixes values of particles' two consecutive properties between two values based on their time alive.
* Added new struct `BBMOD_MixVec3OverTimeModule`, which is a universal particle module that mixes values of particles' three consecutive properties between two values based on their time alive.
* Added new struct `BBMOD_MixVec4OverTimeModule`, which is a universal particle module that mixes values of particles' four consecutive properties between two values based on their time alive.
* Added new struct `BBMOD_MixColorFromHealthModule`, which is a universal particle module that mixes particles' color property between two values based on their remaining health.
* Added new struct `BBMOD_MixQuaternionFromHealthModule`, which is a universal particle module that mixes particles' quaternion property between two values based on their remaining health.
* Added new struct `BBMOD_MixRealFromHealthModule`, which is a universal particle module that mixes value of particles' property between two values based on their remaining health.
* Added new struct `BBMOD_MixVec2FromHealthModule`, which is a universal particle module that mixes values of particles' two consecutive properties between two values based on their remaining health.
* Added new struct `BBMOD_MixVec3FromHealthModule`, which is a universal particle module that mixes values of particles' three consecutive properties between two values based on their remaining health.
* Added new struct `BBMOD_MixVec4FromHealthModule`, which is a universal particle module that mixes values of particles' four consecutive properties between two values based on their remaining health.
* Added new struct `BBMOD_MixColorFromSpeedModule`, which is a universal particle module that mixes particles' color property between two values based on the magnitude of their velocity vector.
* Added new struct `BBMOD_MixQuaternionFromSpeedModule`, which is a universal particle module that mixes particles' quaternion property between two values based on the magnitude of their velocity vector.
* Added new struct `BBMOD_MixRealFromSpeedModule`, which is a universal particle module that mixes value of particles' property between two values based on the magnitude of their velocity vector.
* Added new struct `BBMOD_MixVec2FromSpeedModule`, which is a universal particle module that mixes values of particles' two consecutive properties between two values based on the magnitude of their velocity vector.
* Added new struct `BBMOD_MixVec3FromSpeedModule`, which is a universal particle module that mixes values of particles' three consecutive properties between two values based on the magnitude of their velocity vector.
* Added new struct `BBMOD_MixVec4FromSpeedModule`, which is a universal particle module that mixes values of particles' four consecutive properties between two values based on the magnitude of their velocity vector.
* Added new struct `BBMOD_AddRealOverTimeModule`, which is a universal particle module that adds a value to particles' property over time.
* Added new struct `BBMOD_AddVec2OverTimeModule`, which is a universal particle module that adds a value to two consecutive particle properties over time.
* Added new struct `BBMOD_AddVec3OverTimeModule`, which is a universal particle module that adds a value to three consecutive particle properties over time.
* Added new struct `BBMOD_AddVec4OverTimeModule`, which is a universal particle module that adds a value to four consecutive particle properties over time.
* Added new struct `BBMOD_AddRealOnCollisionModule`, which is a  universal particle module that adds a value to particles' property when they have a collision.
* Added new struct `BBMOD_AddVec2OnCollisionModule`, which is a universal particle module that adds a value to two consecutive particle properties it has a collision.
* Added new struct `BBMOD_AddVec3OnCollisionModule`, which is a universal particle module that adds a value to three consecutive particle properties it has a collision.
* Added new struct `BBMOD_AddVec4OnCollisionModule`, which is a universal particle module that adds a value to four consecutive particle properties it has a collision.
* Added new struct `BBMOD_AttractorModule`, which is a a particle module that attracts/repels particles to/from a given position.
* Added new struct `BBMOD_DragModule`, which is a particle module that applies drag force to particles.
* Added new struct `BBMOD_GravityModule`, which is a particle module that applies gravity force to particles.
* Added new struct `BBMOD_TerrainCollisionModule`, which is a particle module that handles collisions with a terrain.
* Added new struct `BBMOD_CollisionEventModule`, which is a particle module that executes a callback on particle collision.
* Added new struct `BBMOD_CollisionKillModule`, which is a particle module that kills all particles that had a collision.
