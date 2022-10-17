# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

## GML API:
### Core module:
* `BBMOD_RenderQueue.set_sampler` now also accepts a specific index instead of just a uniform name. This is useful for HLSL11.

### Camera module:
* Added new property `Up` to `BBMOD_Camera`, which is the camera's up vector.
* Changed `BBMOD_Camera.AspectRatio`'s default value to `window width / window height`. Previously it was set to `16 / 9`.
* Added new struct `BBMOD_BaseCamera`, which inherits from `BBMOD_Class` and it is now the base struct for cameras. It has a `destroy` method that destroys the raw GameMaker camera!
* Struct `BBMOD_Camera` now inherits from `BBMOD_BaseCamera`.
