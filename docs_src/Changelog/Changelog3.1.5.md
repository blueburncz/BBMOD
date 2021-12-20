# Changelog 3.1.5
This release adds color grading, chromatic aberration, grayscale and vignette post-processing effects and fast approximate anti-aliasing (FXAA) to renderer. Additionally animation player now supports frame skipping, using which you can for example increase performance when rendering animated characters in the distance by skipping over few frames.

## GML API:
### Core module:
* Added new property `Frameskip` to `BBMOD_AnimationPlayer` using which you can configure number of frames to skip during animation playback.

### Rendering module:
* Added new submodule - FXAA - containing fast approximate anti-aliasing shader.
* Added new submodule - Post-processing - containing post-processing shaders.

#### Renderer submodule:
* Added new enum `BBMOD_EAntialiasing`, containing all possible anti-aliasing types.
* Added new property `Antialiasing` to `BBMOD_Renderer`, using which you can configure which anti-aliasing type to use. Enabling AA will also require appropriate submodule.
* Added new property `EnablePostProcessing` to `BBMOD_Renderer`, using which you can enable post-processing effects. Enabling this will require the post-processing submodule.
* Added new property `ColorGradingLUT` to `BBMOD_Renderer`, using which you can configure lookup table texture for color grading.
* Added new property `ChromaticAberration` to `BBMOD_Renderer`, using which you can configure strength of chromatic aberration effect.
* Added new property `Grayscale` to `BBMOD_Renderer`, using which you can configure strength of grayscale effect.
* Added new property `Vignette` to `BBMOD_Renderer`, using which you can configure strength of vignette effect.
* Overridden method `destroy` of `BBMOD_Renderer` to fix shadowmap memory leaks. Do not forget to call this method before a renderer instance goes out of scope.
