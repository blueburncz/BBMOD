# Changelog 3.6.0
This release adds a new rendering submodule - SSAO (screen-space ambient occlusion).

## GML API:
### Rendering module:
#### Renderer submodule:
* Added new property `EnableGBuffer` to `BBMOD_Renderer`, which enables rendering into a G-buffer surface in the deferred pass.
* Added new property `GBufferScale` to `BBMOD_Renderer`, which is a resolution multiplier for the G-buffer surface.
* Added new property `EnableSSAO` to `BBMOD_Renderer`, which enables screen-space ambient occlusion. This requires G-buffer and the SSAO submodule!
* Added new property `SSAOScale` to `BBMOD_Renderer`, which is a resolution multiplier for SSAO surface.
* Added new property `SSAORadius` to `BBMOD_Renderer`, which is a screen-space radius of SSAO.
* Added new property `SSAOPower` to `BBMOD_Renderer`, which is the strength of the SSAO effect.
* Added new property `SSAOAngleBias` to `BBMOD_Renderer`, which is SSAO angle bias in radians.
* Added new property `SSAODepthRange` to `BBMOD_Renderer`, which is the maximum depth difference of SSAO samples. Samples farther way from the origin than this will not contribute to the effect.

#### SSAO submodule:
* Added new submodule - SSAO.
* Added new function `bbmod_ssao_draw`, which renders SSAO into a surface.
