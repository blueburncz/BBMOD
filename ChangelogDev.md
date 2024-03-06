# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Added new member `Outline` to enum `BBMOD_ERenderPass`, which is a render pass for model outlines.
* Added new member `Translucent` to enum `BBMOD_ERenderPass`, which is a render pass for translucent object that take a blurred screen surface as an input.
* Added new member `Distortion` to enum `BBMOD_ERenderPass`, which is a render pass for screen distortion effects.
* Fixed a bug where `BBMOD_Resource` was not removed from a `BBMOD_ResourceManager` when destroyed.
