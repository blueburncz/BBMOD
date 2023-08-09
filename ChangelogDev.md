# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Added new property `Colormap` to `BBMOD_Terrain`, which is a texture to multiply the terrain colors with.
* Added new macro `BBMOD_U_COLORMAP`, which is the name of a fragment shader uniform of type `sampler2D` that holds the colormap texture.
* Added new property `ChunkSize` to `BBMOD_Terrain`, which is the width and height of a single terrain chunk. Terrain mesh is now split into chunks which consist of `Chunksize`x`Chunksize` quads.
* Added new optional argument `_chunkSize` to the constructor of `BBMOD_Terrain`. This is the width and height of a single terrain chunk. Defaults to 128.
* Added new property `Chunks` to `BBMOD_Terrain`, which is a grid of vertex buffers, each representing an individual terrain chunk.
* Added new property `ChunksDirty` to `BBMOD_Terrain`, which is a grid of dirty state (boolean) of individual terrain chunks. When a chunk is marked as dirty, it means its vertex buffer should be rebuilt. When a terrain is first created, all its chunks are marked as dirty.
* Added new property `ChunkRadius`, which is the radius (in chunk size) within which terrain chunks are visible around the camera. Zero means only the chunk that the camera is on is visible. Use `infinity` to make all chunks visible. Default value is `infinity`.
* Property `VertexBuffer` of `BBMOD_Terrain` is now **obsolete**! It was replaced with the new `Chunks` property.

* Added new property `Material` to `BBMOD_Terrain`, which is the shader used when rendering the terrain. Default is `BBMOD_MATERIAL_TERRAIN`.
* Added new struct `BBMOD_TerrainLayer`, which describes a material of a single terrain layer.
* Entries in `BBMOD_Terrain.Layer` should now be of `Struct.BBMOD_TerrainLayer` type **instead of** `Struct.BBMOD_DefaultMaterial`!

* Added new member `TerrainDepth` to `BBMOD_ERenderPass`, which is a render pass where only the terrain is rendered into an off-screen depth buffer. Required for terrain editing tools.
* Materials `BBMOD_MATERIAL_TERRAIN` and `BBMOD_SHADER_TERRAIN_UNLIT` now use the `BBMOD_SHADER_DEFAULT_DEPTH` shader in the new `TerrainDepth` render pass.
* Renderers `BBMOD_BaseRenderer` and `BBMOD_DefaultRenderer` now support the new `TerrainDepth` render pass.
* Added new struct `BBMOD_TerrainShader`, which is the base class for BBMOD terrain shaders.
* Shaders `BBMOD_SHADER_TERRAIN` and `BBMOD_SHADER_TERRAIN_UNLIT` are now constructed from `BBMOD_TerrainShader`.
