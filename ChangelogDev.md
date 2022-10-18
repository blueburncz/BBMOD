# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

## GML API:
### Core module:
* Method `BBMOD_RenderQueue.set_sampler` now also accepts a specific index instead of just a uniform name. This is useful for HLSL11, which does not have the `uniform` keyword.
* Added new struct `BBMOD_PunctualLight`, which is a base struct for punctual lights.
* Struct `BBMOD_PointLight` now inherits from `BBMOD_PunctualLight`.
* Added new struct `BBMOD_SpotLight`, which is a new punctual light - a spot light.
* Added new function `bbmod_light_punctual_add`, which adds a punctual light to be sent to shaders.
* Added new function `bbmod_light_punctual_count`, which retrieves number of punctual lights added to be sent to shaders.
* Added new function `bbmod_light_punctual_get`, which retrieves a punctual light at given index.
* Added new function `bbmod_light_punctual_remove`, which removes a punctual light so it is not sent to shaders anymore.
* Added new function `bbmod_light_punctual_remove_index`, which removes a punctual light so it is not sent to shaders anymore.
* Added new function `bbmod_light_punctual_clear`, which removes all punctual lights sent to shaders.
* Functions `bbmod_light_point_add`, `bbmod_light_point_count`, `bbmod_light_point_get`, `bbmod_light_point_remove`, `bbmod_light_point_remove_index` and `bbmod_light_point_clear` are now deprecated. Please use the new `bbmod_light_punctual_*` functions instead.
* Added new property `MaxPunctualLights` to `BBMOD_BaseShader`, which is the maximum number of punctual lights in the shader. This must match with value defined in the raw GameMaker shader!
* Property `MaxPointLights` of `BBMOD_BaseShader` is now obsolete. Please use the new `MaxPunctualLights` instead.
* Added new method `set_punctual_lights` to `BBMOD_BaseShader`, which sets uniform `bbmod_LightPunctualData`.
* Method `set_point_lights` of `BBMOD_BaseShader` is now deprecated, please use the new `set_punctual_lights` instead.

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
