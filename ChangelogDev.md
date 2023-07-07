# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* **Replaced** arguments `_vertexBuffer`, `_vertexFormat`, `_primitiveType` and `_materialIndex` of methods `DrawMesh`, `DrawMeshAnimated` and `DrawMeshBatched` of `BBMOD_RenderQueue` with a single `_mesh` argument, which is the `Struct.BBMOD_Mesh` to be rendered!
* Fixed methods `BBMOD_RenderQueue.DrawMeshBatched` not setting uniform `BBMOD_U_MATERIAL_INDEX`.
