# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Renderer `BBMOD_DeferredRenderer` now also supports the `DepthOnly` render pass and blends depth of forward rendered models into the G-Buffer.
* Fixed normal mapping on terrain.
* Fixed crash that happens in recent releases of GameMaker in function `bbmod_texture_set_stage_vs` when running on macOS and `libBBMOD.dylib` is missing.
* Fixed materials `BBMOD_MATERIAL_DEFERRED` and `BBMOD_TERRAIN_DEFERRED` being registered under wrong names and hence being loaded incorrectly from BBMAT files.
