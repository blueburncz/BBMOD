# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Added new macro `BBMOD_U_BASE_OPACITY`, which is the name of a fragment shader uniform of type `sampler2D` that holds a texture with base color in RGB channels and opacity in the A channel.
* Struct `BBMOD_MaterialPropertyBlock` can now also override the base opacity texture using the new `BBMOD_U_BASE_OPACITY` macro.
* Added new property `ShadowmapFollowsCamera` to `BBMOD_DirectionalLight`, which if set to `true`, then the shadowmap is captured from the camera's position instead of from the directional light's position. Default value is `true` for backwards compatibility.
* Added new property `EnableShadows` to `BBMOD_ReflectionProbe`, which if set to `true`, then shadows are enabled when capturing the reflection probe, which takes longer to render. Default is `false`.
* Fixed camera exposure setting being used also when capturing reflection probes, which effectively caused the exposure to be applied twice, making the scene brighter or darker than it should be.
* Fixed method `render` of `BBMOD_StaticBatch` crashing due to using `BBMOD_RenderQueue` incorrectly.
