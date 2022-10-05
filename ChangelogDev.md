# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Fixed mipmapping not working for externally loaded textures.
* Fixed `BBMOD_ResourceManager` not remembering loaded materials.
* Fixed `BBMOD_Material.apply` always resetting shader, even when it wasn't necessary. This should slightly increase rendering performance.
* Added optional argument `_position` to method `spawn_particle` of `BBMOD_ParticleEmitter`, which is the position to spawn the particle at. If not specified, it defaults to the particle emitter's position.
