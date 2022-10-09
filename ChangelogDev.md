# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Fixed mipmapping not working for externally loaded textures.
* Fixed `BBMOD_ResourceManager` not remembering loaded materials.
* Fixed `BBMOD_Material.apply` always resetting shader, even when it wasn't necessary. This should slightly increase rendering performance.
* Added optional argument `_position` to method `spawn_particle` of `BBMOD_ParticleEmitter`, which is the position to spawn the particle at. If not specified, it defaults to the particle emitter's position.
* Data for dynamic batching passed to methods `submit`, `render` of `BBMOD_Model` and `BBMOD_DynamicBatch` and method `BBMOD_RenderQueue.draw_mesh_batched` can now also be array of arrays of data. This has the same effect like if you called these methods multiple times with the individual arrays, but it has better performance.
* Added new optional argument `_batchData` to methods `submit` and `render` of `BBMOD_Model`, which is data for dynamic batching.
* Added new read-only property `Frozen` to `BBMOD_Model`, which is set to `true` when the model is frozen.
* Added new read-only property `Frozen` to `BBMOD_Mesh`, which is set to `true` when the mesh is frozen.
* Added new method `copy` to `BBMOD_Model`, which deeply copies model's data into another model.
* Added new method `clone` to `BBMOD_Model`, which creates a deep clone of the model.
* Added new method `copy` to `BBMOD_Node`, which deeply copies node's data into another node.
* Added new method `clone` to `BBMOD_Node`, which creates a deep clone of the node.
* Added new method `copy` to `BBMOD_Mesh`, which deeply copies mesh's data into another mesh.
* Added new method `clone` to `BBMOD_Mesh`, which creates a deep clone of the mesh.
