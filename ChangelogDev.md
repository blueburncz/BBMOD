# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Moved properties `EnableSSAO`, `SSAOScale`, `SSAORadius`, `SSAOPower`, `SSAOAngleBias`, `SSAODepthRange`, `SSAOSelfOcclusionBias` and `SSAOBlurDepthRange` from `BBMOD_DefaultRenderer` to `BBMOD_BaseRenderer`.
* `BBMOD_PointLight` can now also cast shadows.
* Added new property `Frameskip` to `BBMOD_Light`, which is the number of frames to skip between individual updates of the light's shadowmap.
* Added new property `Static` to `BBMOD_Light`, which when set to `true`, the light's shadowmap is captured only once.
* Added new property `NeedsUpdate` to `BBMOD_Light`, which if `true`, then the light's shadowmap needs to be updated.
* Added new function `bbmod_hdr_is_supported`, which checks whether high dynamic range (HDR) rendering is supported on the current platform.
* Added new macro `BBMOD_U_HDR`, which is the name of a fragment shader uniform of type `float` that holds whether HDR rendering is enabled (1.0) or not (0.0).
* Fixed function `bbmod_mrt_is_supported` not working on Mac.
* Fixed method `clone` of `BBMOD_TerrainMaterial`, which returned instances of `BBMOD_BaseMaterial`.
* Fixed materials with `AlphaBlend` enabled not working in the `Id` render pass.
