# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Added new interface `BBMOD_IMeshRenderQueue`, which is an interface for render queues that can draw meshes.
* **Replaced** arguments `_vertexBuffer`, `_vertexFormat`, `_primitiveType` and `_materialIndex` of methods `DrawMesh`, `DrawMeshAnimated` and `DrawMeshBatched` of `BBMOD_RenderQueue` with a single `_mesh` argument, which is the `Struct.BBMOD_Mesh` to be rendered!
* Struct `BBMOD_RenderQueue` now implements the `BBMOD_IMeshRenderQueue` interface.
* Fixed methods `BBMOD_RenderQueue.DrawMeshBatched` not setting uniform `BBMOD_U_MATERIAL_INDEX`.
* Added new struct `BBMOD_MeshRenderQueue`, which is a render queue specialized for rendering of multiple instances of a model, where all instances are using the same material. You can use this instead of `BBMOD_RenderQueue` to increase rendering performance.
