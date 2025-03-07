# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Fixed not all parameters of `BBMOD_DepthOfFieldEffect` constructors being used.
* Fixed property `Sprite` of struct `BBMOD_LensFlareElement` defaulting to sprite `BBMOD_SprLensFlareGhost`, which does not exist. Now it defaults to `BBMOD_SprLensFlareHeptagon`.
* Fixed loading of "Lightmap" textures from `*.bbmat` files for `BBMOD_MATERIAL_DEFAULT_LIGHTMAP` materials.
* Added new utility function `bbmod_is_browser()`, which returns `true` if the game is running in a browser.
* Fixed `BBMOD_Camera`'s mouselook not working on GX.games platform.
* Fixed default shaders not compiling on GX.games platform.
