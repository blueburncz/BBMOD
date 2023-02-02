# Changelog 3.16.6
This release fixes SSAO when using orthographic projection and adds more options to control SSAO quality with.

* Added new property `SSAOSelfOcclusionBias` to `BBMOD_DefaultRenderer`, which defaults to 0.01. Increase to fix self-occlusion.
* Added new property `SSAOBlurDepthRange` to `BBMOD_DefaultRenderer`, which is the maximum depth difference over which can be SSAO samples blurred. Defaults to 2.
* Added new optional arguments `_selfOcclusionBias` and `_blurDepthRange` to function `bbmod_ssao_draw`, using which you can configure self-occlusion bias and blur depth range respectively.
* Fixed SSAO when using orthographic projection.
