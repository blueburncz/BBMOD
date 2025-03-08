# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Fixed not all parameters of `BBMOD_DepthOfFieldEffect` constructors being used.
* Fixed property `Sprite` of struct `BBMOD_LensFlareElement` defaulting to sprite `BBMOD_SprLensFlareGhost`, which does not exist. Now it defaults to `BBMOD_SprLensFlareHeptagon`.
* Fixed loading of "Lightmap" textures from `*.bbmat` files for `BBMOD_MATERIAL_DEFAULT_LIGHTMAP` materials.
* Added new utility function `bbmod_is_browser()`, which returns `true` if the game is running in a browser.
* Added new utility functions `bbmod_window_get_width()` and `bbmod_window_get_height()`, which return the width and the height of the game window respectively. This is useful for GX.games platform, where `window_get_width()` and `window_get_height()` do not return the desired value.
* Fixed `BBMOD_Camera`'s mouselook not working on GX.games platform.
* Fixed default shaders not compiling on GX.games platform.
* Fixed post-processing effects `BBMOD_DepthOfFieldEffect`, `BBMOD_DirectionalBlurEffect`, `BBMOD_RadialBlurEffect` and `BBMOD_SunShaftEffect` not working on GX.games platform.
* **Disabled** property `RenderScale` on GX.games and HTML5 platforms, as it does not work properly!
