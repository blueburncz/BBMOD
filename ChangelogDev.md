# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Added new property `Frameskip` to `BBMOD_Light`, which is the number of frames to skip between individual updates of the light's shadowmap.
* Added new property `Static` to `BBMOD_Light`, which when set to `true`, the light's shadowmap is captured only once.
* Added new property `NeedsUpdate` to `BBMOD_Light`, which if `true`, then the light's shadowmap needs to be updated.
* Fixed method `clone` of `BBMOD_TerrainMaterial`, which returned instances of `BBMOD_BaseMaterial`.
