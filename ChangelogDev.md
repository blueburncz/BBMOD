# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

## GML API:
### Camera module:
* Added `Up`.
* Changed `AspectRatio` default value to window width / window height.
* Added `BBMOD_BaseCamera`, which inherits from `BBMOD_Class`. There's now a `destroy` method that destroys the raw camera!
* `BBMOD_Camera` now inherits from `BBMOD_BaseCamera`.
