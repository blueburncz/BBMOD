# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Added new member `Outline` to enum `BBMOD_ERenderPass`, which is a render pass for model outlines. Please note that this is not yet used.
* Added new member `Translucent` to enum `BBMOD_ERenderPass`, which is a render pass for translucent object that take a blurred screen surface as an input. Please note that this is not yet used.
* Added new member `Distortion` to enum `BBMOD_ERenderPass`, which is a render pass for screen distortion effects. Please note that this is not yet used.
* Fixed a bug where `BBMOD_Resource` was not removed from a `BBMOD_ResourceManager` when destroyed.
* Added new struct `BBMOD_Rect`, which is a rectangle structure defined by position and size.
* Fixed depth in deferred rendering pipeline being cleared to 0 instead of 1, which was inconsistent with the forward renderer and made particles invisible when not rendered over solid geometry (e.g. only a sky dome was behind).
* Added shadowmap stabilization for directional lights to reduce flickering when the camera is moving.
* Fixed shading of backfacing polygons.
