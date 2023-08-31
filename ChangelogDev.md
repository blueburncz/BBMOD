# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Added new property `LayersPerDrawCall` to `BBMOD_TerrainShader`, which is the number of terrain layers that the terrain shader can render in a single draw call.
* Added new property `MaxLayers` to `BBMOD_TerrainShader`, which is the maximum number of terrain layers that the terrain shader supports.
* Added new macros `BBMOD_U_TERRAIN_BASE_OPACITY_0`..`BBMOD_U_TERRAIN_BASE_OPACITY_4`, which are the names of fragment shader uniforms of type `sampler2D` that hold a texture with base color in RGB channels and opacity in the A channel for the first, second, third, fourth and fifth terrain layer rendered in a single draw call.
* Added new macros `BBMOD_U_TERRAIN_NORMAL_W_0`..`BBMOD_U_TERRAIN_NORMAL_W_4`, which are the names of fragment shader uniforms of type `sampler2D` that hold normal smoothness/roughness texture for the first, second, third, fourth and fifth terrain layer rendered in a single draw call.
* Added new macros `BBMOD_U_TERRAIN_IS_ROUGHNESS_0`..`BBMOD_U_TERRAIN_IS_ROUGHNESS_4`, which are the name of fragment shader uniforms of type `float` that hold whether the first, second, third, fourth and fifth terrain material layer uses roughness workflow (1.0) or not (0.0).
* Added new macros `BBMOD_U_SPLATMAP_INDEX_0`..`BBMOD_U_SPLATMAP_INDEX_4`, which are the names of fragment shader uniforms of type `int` that hold the index of a channel to read from the splatmap for the first, second, third, fourth and fifth terrain layer rendered in a draw call.
* Macro `BBMOD_U_SPLATMAP_INDEX` is now obsolete! Please use `BBMOD_U_SPLATMAP_INDEX_0` instead.
* Added new macro `BBMOD_U_BASE_OPACITY`, which is the name of a fragment shader uniform of type `sampler2D` that holds a texture with base color in RGB channels and opacity in the A channel.
* Struct `BBMOD_MaterialPropertyBlock` can now also override the base opacity texture using the new `BBMOD_U_BASE_OPACITY` macro.
* Added new property `ShadowmapFollowsCamera` to `BBMOD_DirectionalLight`, which if set to `true`, then the shadowmap is captured from the camera's position instead of from the directional light's position. Default value is `true` for backwards compatibility.
* Added new property `EnableShadows` to `BBMOD_ReflectionProbe`, which if set to `true`, then shadows are enabled when capturing the reflection probe, which takes longer to render. Default is `false`.
* Fixed camera exposure setting being used also when capturing reflection probes, which effectively caused the exposure to be applied twice, making the scene brighter or darker than it should be.
* Fixed method `render` of `BBMOD_StaticBatch` crashing due to using `BBMOD_RenderQueue` incorrectly.
