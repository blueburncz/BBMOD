# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

## GML API:
### Core module:
* Method `BBMOD_RenderQueue.set_sampler` now also accepts a specific index instead of just a uniform name. This is useful for HLSL11, which does not have the `uniform` keyword.
* Added new struct `BBMOD_SpotLight`, which is a spot light.

### Camera module:
* Added new property `Up` to `BBMOD_Camera`, which is the camera's up vector.
* Changed `BBMOD_Camera.AspectRatio`'s default value to `window width / window height`. Previously it was set to `16 / 9`.
* Added new struct `BBMOD_BaseCamera`, which inherits from `BBMOD_Class` and it is now the base struct for cameras. It has a `destroy` method that destroys the raw GameMaker camera!
* Struct `BBMOD_Camera` now inherits from `BBMOD_BaseCamera`.

## Raycasting module:
* Added new struct `BBMOD_FrustumCollider`, which is a frustum collider that can be initialized from any view-projection matrix or a `BBMOD_Camera`.
* Added new method `TestFrustum` to `BBMOD_Collider`, which tests whether a collider intersects with a frustum collider. This method is by default not implemented and it will throw a `BBMOD_NotImplementedException`!
* Implemented method `TestFrustum` for `BBMOD_SphereCollider`.

## Rendering module:
### Post-processing submodule:
* Added new struct `BBMOD_PostProcessor`, which handles post-processing effects.

### Renderer submodule:
* Moved enum `BBMOD_EAntialiasing` from the Renderer submodule to the Post-processing submodule.
* Moved properties `ColorGradingLUT`, `ChromaticAberration`, `Grayscale`, `Vignette`, `VignetteColor` and `Antialiasing` from `BBMOD_Renderer` to `BBMOD_PostProcessor`.
* Added new property `PostProcessor` to `BBMOD_Renderer`, which is an instance of post-processor. Default is `undefined`.
* Property `EnablePostProcessing` of `BBMOD_Renderer` is now obsolete.
