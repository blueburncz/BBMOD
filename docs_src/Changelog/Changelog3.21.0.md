# Changelog 3.21.0
This release brings a massive overhaul to the post-processing system. Post-processing effects are now individual structs that are added to a post-processor, which then executes them in order, making the system fully customisable. Many new post-processing effects were added. HDR post-processing effects are available when using the deferred renderer. Various smaller fixes and improvements are also included in this release.

* Added new struct `BBMOD_Rect`, which is a rectangle structure defined by position and size.
* Added new struct `BBMOD_PostProcessEffect`, which is a base struct for all post-processing effects.
* Added new method `add_effect(_effect)` to `BBMOD_PostProcessor`, which adds an effect to the post-processor.
* Added new method `remove_effect(_effect)` to `BBMOD_PostProcessor`, which removes an effect from the post-processor.
* Method `draw` of `BBMOD_PostProcessor` now accepts optional arguments `_depth` and `_normals`, where `_depth` is a surface containing the scene depth encoded into RGB channels or `undefined` if not available, and `_normals` a surface containing the scene's world-space normals in the RGB channels or `undefined` if not available.
* Added new property `DesignWidth` to `BBMOD_PostProcessor`, which is the width of the screen for which was the game designed or `undefined`. Effects are scaled based on this and the current width of the screen if not `undefined`. Default value is 1366.
* Added new property `DesignHeight` to `BBMOD_PostProcessor`, which is the height of the screen for which was the game designed or `undefined`. Effects are scaled based on this and the current height of the screen if not `undefined`. Default value is `undefined`.
* Added new method `get_effect_scale()` to `BBMOD_PostProcessor`, which retrieves the current effect scale based on the current screen size and properties `DesignWidth` and `DesignHeight`.
* Added new read-only property `Rect` to `BBMOD_PostProcessor`, which is the screen size and position. This is not initialized before `BBMOD_PostProcessor.draw` is called!
* Added new property `LensDirt` to `BBMOD_PostProcessor`, which is a lens dirt texture applied to effects like light bloom and lens flares.
* Added new property `LensDirtStrength`, which is the intensity of the lens dirt effect.
* Added new property `Starburst` to `BBMOD_PostProcessor`, which is a starburst texture applied to lens flares (when enabled).
* Added new property `StarburstStrength`, which is the intensity of the starburst effect.
* Added new struct `BBMOD_ChromaticAberrationEffect`, which is a chromatic aberration post-processing effect.
* Added new struct `BBMOD_ColorGradingEffect`, which is a color grading post-processing effect.
* Added new struct `BBMOD_DepthOfFieldEffect`, which is a depth of field post-processing effect.
* Added new struct `BBMOD_DirectionalBlurEffect`, which is a directional blur post-processing effect.
* Added new struct `BBMOD_ExposureEffect`, which is a post-processing effect that applies camera exposure.
* Added new struct `BBMOD_FilmGrainEffect`, which is a film grain post-processing effect.
* Added new struct `BBMOD_FXAAEffect`, which is a fast approximate anti-aliasing post-processing effect.
* Added new struct `BBMOD_GammaCorrectEffect`, which is a post-processing effect that applies gamma correction.
* Added new struct `BBMOD_KawaseBlurEffect`, which is a Kawase blur post-processing effect.
* Added new struct `BBMOD_LensDistortionEffect`, which is a barell/pincushion lens distortion post-processing effect.
* Added new struct `BBMOD_LensFlareElement`, which is a single lens flare element (sprite).
* Added new struct `BBMOD_LensFlare`, which is a collection of `BBMOD_LensFlareElement`s that together define a single lens flare instance.
* Added new function `bbmod_lens_flare_add(_lensFlare)`, which adds a lens flare to be drawn with `BBMOD_LensFlaresEffect`.
* Added new function `bbmod_lens_flare_count()`, which retrieves number of lens flares to be drawn.
* Added new function `bbmod_lens_flare_get(_index)`, which retrieves a lens flare at given index.
* Added new function `bbmod_lens_flare_remove(_lensFlare)`, which removes a lens flare so it is not drawn anymore.
* Added new function `bbmod_lens_flare_remove_index(_index)`, which removes a lens flare so it is not drawn anymore
* Added new function `bbmod_lens_flare_clear()`, which removes all lens flares.
* Added new struct `BBMOD_LensFlaresEffect`, which is a post-processing effect that draws all lens flares added with `bbmod_lens_flare_add`.
* Added new struct `BBMOD_LightBloomEffect`, which is a light bloom post-processing effect.
* Added new struct `BBMOD_LumaSharpenEffect`, which is a luma sharpen post-processing effect.
* Added new struct `BBMOD_MonochromeEffect`, which is a monochrome post-processing effect.
* Added new struct `BBMOD_NormalDistortionEffect`, which is a post-processing effect that distort screen using a normal map texture.
* Added new struct `BBMOD_RadialBlurEffect`, which is a radial blur post-processing effect.
* Added new struct `BBMOD_ReinhardTonemapEffect`, which is a Reinhard tonemapping post-processing effect.
* Added new struct `BBMOD_SunShaftsEffect`, which is a sun shafts post-processing effect.
* Added new struct `BBMOD_VignetteEffect`, which is a vignette post-processing effect.
* Property `ColorGradingLUT` of `BBMOD_PostProcessor` is now **obsolete**! Please use the new `BBMOD_ColorGradingEffect` instead.
* Properties `ChromaticAberration` and `ChromaticAberrationOffset` of `BBMOD_PostProcessor` are now **obsolete**! Please use the new `BBMOD_ChromaticAberrationEffect` instead.
* Property `Grayscale` of `BBMOD_PostProcessor` is now **obsolete**! Please use the new `BBMOD_MonochromeEffect` instead.
* Properties `Vignette` and `VignetteColor` of `BBMOD_PostProcessor` are now **obsolete**! Please use the new `BBMOD_VignetteEffect` instead.
* Property `Antialiasing` of `BBMOD_PostProcessor` is now **obsolete**! Please use the new `BBMOD_FXAAEffect` instead.
* Enum `BBMOD_EAntialiasing` is now **obsolete**! Please use the new `BBMOD_FXAAEffect` instead.
* Method `world_to_screen` of `BBMOD_BaseCamera` now also accepts `BBMOD_Vec4`s, using which you can project directions (`W` equal to 0) as well instead of just positions (`W` equal to 1).
* Added shadowmap stabilization for directional lights to reduce flickering when the camera is moving.
* Added new member `Outline` to enum `BBMOD_ERenderPass`, which is a render pass for model outlines. Please note that this is not yet used.
* Added new member `Translucent` to enum `BBMOD_ERenderPass`, which is a render pass for translucent object that take a blurred screen surface as an input. Please note that this is not yet used.
* Added new member `Distortion` to enum `BBMOD_ERenderPass`, which is a render pass for screen distortion effects. Please note that this is not yet used.
* Fixed a bug where `BBMOD_Resource` was not removed from a `BBMOD_ResourceManager` when destroyed.
* Fixed method `load` of `BBMOD_ResourceManager` which executed callback multiple times when loading models with materials.
* Fixed depth in deferred rendering pipeline being cleared to 0 instead of 1, which was inconsistent with the forward renderer and made particles invisible when not rendered over solid geometry (e.g. only a sky dome was behind).
* Fixed shading of backfacing polygons.
* Fixed rpaths for BBMOD CLI on macOS.
