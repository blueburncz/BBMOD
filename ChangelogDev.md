# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Fixed mipmapping not working for externally loaded textures.
* Fixed `BBMOD_ResourceManager` not remembering loaded materials.
* Fixed `BBMOD_Material.apply` always resetting shader, even when it wasn't necessary. This should slightly increase rendering performance.
* Added optional argument `_position` to method `spawn_particle` of `BBMOD_ParticleEmitter`, which is the position to spawn the particle at. If not specified, it defaults to the particle emitter's position.
* Data for dynamic batching passed to methods `submit`, `render` of `BBMOD_Model` and `BBMOD_DynamicBatch` and method `BBMOD_RenderQueue.draw_mesh_batched` can now also be array of arrays of data. This has the same effect like if you called these methods multiple times with the individual arrays, but it has better performance.
* Added new function `bbmod_array_clone`, which creates a shallow clone of an array.
* Added new function `bbmod_array_to_buffer`, which writes an array into a buffer.
* Added new function `bbmod_array_from_buffer`, which creates an array with values from a buffer.
* Added new read-only property `Frozen` to `BBMOD_Model`, which is set to `true` when the model is frozen.
* Added new read-only property `Frozen` to `BBMOD_Mesh`, which is set to `true` when the mesh is frozen.
* Added new method `copy` to `BBMOD_Model`, which deeply copies model's data into another model.
* Added new method `clone` to `BBMOD_Model`, which creates a deep clone of the model.
* Added new method `copy` to `BBMOD_Node`, which deeply copies node's data into another node.
* Added new method `clone` to `BBMOD_Node`, which creates a deep clone of the node.
* Added new method `copy` to `BBMOD_Mesh`, which deeply copies mesh's data into another mesh.
* Added new method `clone` to `BBMOD_Mesh`, which creates a deep clone of the mesh.
* Added support for models with multiple materials to `BBMOD_DynamicBatch`.
* Arguments `_model` and `_size` of constructor of `BBMOD_DynamicBatch` are now optional.
* Added new method `from_model` to `BBMOD_DynamicBatch`, using which you can create the model batch later when `_model` is not passed to the constructor.
* Added optional argument `_slotsPerInstance` to constructor of `BBMOD_DynamicBatch`, which is the number of slots that each instance takes in the data array.
* Added new read-only property `SlotsPerInstance` to `BBMOD_DynamicBatch`, which is the number of slots that each instance takes in the data array.
* Added new read-only property `BatchLength` to `BBMOD_DynamicBatch`, which is the total length of batch data array for a single draw call.
* Added new read-only property `Batch` to `BBMOD_DynamicBatch`, which is the batched version of the model.
* Added new read-only property `InstanceCount` to `BBMOD_DynamicBatch`, which is the number of instances currently added to the dynamic batch.
* Added new property `DataWriter` to `BBMOD_DynamicBatch`, which is a function that writes instance data into the batch data array. It defaults to `BBMOD_DynamicBatch.default_fn`.
* Added new method `add_instance` to `BBMOD_DynamicBatch`, which adds an instance to the dynamic batch.
* Added new method `update_instance` to `BBMOD_DynamicBatch`, which updates batch data for given instance.
* Added new method `remove_instance` to `BBMOD_DynamicBatch`, which removes an instance from the dynamic batch.
* Arguments `_materials` of method `submit` and `render` of `BBMOD_DynamicBatch` is now optional.
* Added new optional argument `_batchData` to methods `submit` and `render` of `BBMOD_Model`, which is data for dynamic batching.
* Arguments `_materials` and `_fn` of method `submit_object` and `render_object` of `BBMOD_DynamicBatch` are now optional.
