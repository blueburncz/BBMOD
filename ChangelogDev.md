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

## Rendering module:
### Post-processing submodule:
* Added new submodule - Post-processing.
* Added new struct `BBMOD_PostProcessor`, which handles post-processing effects.

### Renderer submodule:
* Moved enum `BBMOD_EAntialiasing` from the Renderer submodule to the new Post-processing submodule.
* Moved properties `ColorGradingLUT`, `ChromaticAberration`, `Grayscale`, `Vignette`, `VignetteColor` and `Antialiasing` from `BBMOD_Renderer` to `BBMOD_PostProcessor`.
* Added new property `PostProcessor` to `BBMOD_Renderer`, which is an instance of post-processor. Default is `undefined`.
* Property `EnablePostProcessing` of `BBMOD_Renderer` is now obsolete.
