# Changelog 3.6.1
This release mainly fixes rendering of models that are animated using scene graph nodes instead of skeletal animations. Additionally, each sub-mesh of a model can now have a different vertex format, which allows you to use both scene graph and skeletal animations in a single model. Pointlist and linelist primitive type of meshes are now also supported. Re-conversion of models using new BBMOD CLI is not required, but it is advised.

## CLI:
* Updated Assimp to v5.2.4.
* Added new option `-v`, which shows version info and exits.
* Fixed export of bounding boxes for meshes.
* Added support for pointlist and linelist meshes.
* Using animation optimization level 2 now also includes world-space transforms of nodes, which allows you to use bone attachments.

## GML API:
### Core module:
* Added new property `VertexFormat` to `BBMOD_Mesh`, which is the vertex format of the mesh.
* Property `VertexFormat` of `BBMOD_Model` is now obsolete - each mesh has its own vertex format.
* Property `IsSkeleton` and method `set_skeleton` of `BBMOD_Node` are now obsolete.
* Added new property `PrimitiveType` to `BBMOD_Mesh`, `BBMOD_DynamicBatch` and `BBMOD_StaticBatch`, which is the primitive type of the mesh.
* Added new optional argument `_primitiveType` to methods `draw_mesh`, `draw_mesh_animated` and `draw_mesh_batched` of `BBMOD_RenderQueue`, which is the primitive type of the mesh. When not specified, it defaults to `pr_trianglelist`.

### Mesh builder module:
* Added a new property `PrimitiveType` to `BBMOD_MeshBuilder`, which is the primitive type of built meshes.
* Added an optional argument `_primitiveType` to `BBMOD_MeshBuilder`'s constructor, which is the primitive type of built meshes. When not specified, it defaults to `pr_trianglelist`.
* Method `add_face` of `BBMOD_MeshBuilder` now takes variable number of arguments (at least one).
