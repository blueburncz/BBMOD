# Changelog 3.17.2
This small release brings mainly brings a new type of render queue that specializes in rendering multiple instances of a single mesh, where each instance uses the same material. This new render queue can render such meshes faster than the regular one. Additionally, submitting and rendering models now uses cache for node transformations, which decreases number of operations required before a mesh is submitted/rendered and hence increases performance. Building terrain meshes was also optimized.

* Added new interface `BBMOD_IMeshRenderQueue`, which is an interface for render queues that can draw meshes.
* **Replaced** arguments `_vertexBuffer`, `_vertexFormat`, `_primitiveType` and `_materialIndex` of methods `DrawMesh`, `DrawMeshAnimated` and `DrawMeshBatched` of `BBMOD_RenderQueue` with a single `_mesh` argument, which is the `Struct.BBMOD_Mesh` to be rendered!
* Struct `BBMOD_RenderQueue` now implements the `BBMOD_IMeshRenderQueue` interface.
* Fixed methods `BBMOD_RenderQueue.DrawMeshBatched` not setting uniform `BBMOD_U_MATERIAL_INDEX`.
* Added new struct `BBMOD_MeshRenderQueue`, which is a render queue specialized for rendering of multiple instances of a model, where all instances are using the same material. You can use this instead of `BBMOD_RenderQueue` to increase rendering performance.
* Methods `submit` and `render` of `BBMOD_Model` now use caching to increase rendering performance of models that are either fully static or fully vertex-skinned. Models that consist from both static and vertex-skinned meshes cannot utilize this cache.
* Greatly improved performance of method `BBMOD_Terrain.build_mesh`.
