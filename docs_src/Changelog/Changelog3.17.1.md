# Changelog 3.17.1
This release removes all RTTI mechanisms from BBMOD, as they were not used throughout the library and only unnecessarily increased memory consumption. All deprecated methods of `BBMOD_RenderQueue` were also removed. Some bugfixes and rendering optimizations are also included in this release. Please make sure to read this changelog thoroughly before updating to this version!

* **Removed** RTTI mechanisms from BBMOD: removed struct `BBMOD_Class`, macro `BBMOD_CLASS_GENERATED_BODY` and functions `bbmod_is_class` and `bbmod_class_get_name`! This means methods `is_instance`, `implement` and `implements` are also no longer available. Please make sure that you are not using any of these before upgrading to this version!
* Added `BBMOD_IDestructible`, which is an interface for structs that need to be manually destroyed to properly free used memory. Structs that previously inherited from `BBMOD_Class` and still need a `destroy` method now implement this interface. Structs that did not need the method but still had it, because they inherited from `BBMOD_Class`, now do not have the method and trying to call it will give you an error. To fix this, simply remove these calls.
* Optimized method `BBMOD_MaterialPropertyBlock.apply`, which was previously slowed down by using function `variable_struct_get_names`.
* Changed default value of property `Mipmapping` of all materials from `mip_on` to `mip_markedonly` to fix performance issues on some platforms. Please make sure to enable option "Generate mipmaps" in "Texture Groups" settings for texture pages that should have mipmaps.
* Reduced complexity of depth and ID shaders and possibly increased rendering performance on some platforms.
* Added new optional argument `_depthBuffer` to function `bbmod_surface_check`, using which you can configure whether a depth buffer should be created for the surface. Defaults to `true`.
* BBMOD no longer creates depth buffers for surfaces that do not need them (e.g. surfaces for post-processing effects). Likewise it also always creates depth buffers for surfaces that do need them (e.g. the application surface, cubemaps etc.).
* **Removed** all deprecated methods of struct `BBMOD_RenderQueue`!
* Added new render command `BBMOD_ERenderCommand.SetGpuState`, which sets the GPU state.
* Added new method `BBMOD_RenderQueue.SetGpuState(_state)`, which adds a `BBMOD_ERenderCommand.SetGpuState` command into the queue.
* Added new render command `BBMOD_ERenderCommand.SubmitRenderQueue`, which submits another render queue.
* Added new method `BBMOD_RenderQueue.SubmitRenderQueue(_renderQueue)`, which adds a `BBMOD_ERenderCommand.SubmitRenderQueue` command into the queue.
* Fixed methods `DrawSpriteExt`, `DrawSpriteGeneral` and `DrawSpritePart` of `BBMOD_RenderQueue` crashing because of wrong variable names.
* Fixed method `BBMOD_Sprite.from_file_async` passing `Asset.GMSprite` instead of `Struct.BBMOD_Sprite` into the callback function.
* Fixed method `BBMOD_ResourceManager.load` crashing when callback function is not provided.
* Fixed formula used in function `bbmod_lerp_delta_time`.
* Fixed gizmo, which still did not work in 3.17.0.
