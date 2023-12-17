# Changelog 3.20.1
This is a small patch release that fixes a few bugs in the library. As a little bonus, a tiny portion of the `Core` module was moved to a new `Core/Base` subfolder. If you would like to use BBMOD only for rendering of 3D animated models in your GameMaker project, without using its material system and other capabilities, this is the only folder that you need to import into your project.

* Renderer `BBMOD_DeferredRenderer` now also supports the `DepthOnly` render pass and blends depth of forward rendered models into the G-Buffer.
* Fixed normal mapping on terrain.
* Fixed spot lights affecting backsides of models.
* Fixed materials `BBMOD_MATERIAL_DEFERRED` and `BBMOD_TERRAIN_DEFERRED` being registered under wrong names and hence being loaded incorrectly from BBMAT files.
* Fixed crash that happens in recent releases of GameMaker in function `bbmod_texture_set_stage_vs` when running on macOS and `libBBMOD.dylib` is missing.
* Fixed method `RotateOther` of `BBMOD_Quaternion`.
* Fixed method `ScaleSelf` of `BBMOD_DualQuaternion`.
* Property `Materials` of `BBMOD_Model` can now contain also `Pointer.Texture`s instead of `BBMOD_Material`s, but then the model can be rendered only using the `submit` method!
* There is now a new folder `BBMOD/Core/Base`, which contains the absolute minimum required to use BBMOD's animation player in your GameMaker projects. The material system is not included in this folder, meaning you will need to write your own shaders to draw the models. Do not forget to add `#define BBMOD_MATERIAL_DEFAULT -1` to your project if you import only this folder!
