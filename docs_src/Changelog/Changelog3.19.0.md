# Changelog 3.19.0
In this release terrain mesh is split into chunks of configurable size and you can control how many chunks to render from the camera's position. Using this you can create larger terrains and draw just a portion of them to save on triangle count. The terrain now also supports a color map, which multiplies the base texture. Terrain material layers were reworked as a preparation for a deferred rendering pipeline. Please read the following changelog thoroughly before upgrading to this version.

* Added new property `Colormap` to `BBMOD_Terrain`, which is a texture to multiply the terrain colors with.
* Added new macro `BBMOD_U_COLORMAP`, which is the name of a fragment shader uniform of type `sampler2D` that holds the color map texture.
* Added new property `ChunkSize` to `BBMOD_Terrain`, which is the width and height of a single terrain chunk. Terrain mesh is now split into chunks which consist of `Chunksize`x`Chunksize` quads.
* Added new optional argument `_chunkSize` to the constructor of `BBMOD_Terrain`. This is the width and height of a single terrain chunk. Defaults to 128.
* Added new property `Chunks` to `BBMOD_Terrain`, which is a grid of vertex buffers, each representing an individual terrain chunk.
* Added new property `ChunkRadius`, which is the radius (in chunk size) within which terrain chunks are visible around the camera. Zero means only the chunk that the camera is on is visible. Use `infinity` to make all chunks visible. Default value is `infinity`.
* Property `VertexBuffer` of `BBMOD_Terrain` is now **obsolete**! It was replaced with the new `Chunks` property.
* Added new property `Material` to `BBMOD_Terrain`, which is the shader used when rendering the terrain. Default is `BBMOD_MATERIAL_TERRAIN`.
* Added new struct `BBMOD_TerrainLayer`, which describes a material of a single terrain layer.
* Entries in `BBMOD_Terrain.Layer` should now be of `Struct.BBMOD_TerrainLayer` type **instead of** `Struct.BBMOD_DefaultMaterial`!
* Added new struct `BBMOD_TerrainShader`, which is the base class for BBMOD terrain shaders.
* Shaders `BBMOD_SHADER_TERRAIN` and `BBMOD_SHADER_TERRAIN_UNLIT` are now constructed from `BBMOD_TerrainShader`.
* Added new struct `BBMOD_TerrainMaterial`, which is a material that can be used when rendering terrain.
* Materials `BBMOD_MATERIAL_TERRAIN` and `BBMOD_MATERIAL_TERRAIN_UNLIT` are now constructed from `BBMOD_TerrainMaterial`.
* Fixed method `screen_point_to_vec3` of `BBMOD_BaseCamera` normalizing the resulting vector when it should not be normalized.
* Fixed crash after `BBMOD_Camera.set_mouselook(true)` in YYC.
