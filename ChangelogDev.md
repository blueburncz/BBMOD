# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Fixed method `BBMOD_Sprite.from_file_async` passing `Asset.GMSprite` instead of `Struct.BBMOD_Sprite` into the callback function.
* Fixed method `BBMOD_ResourceManager.load` crashing when callback function is not provided.
* Removed all deprecated methods of struct `BBMOD_RenderQueue`!

* Removed RTTI mechanisms from BBMOD: removed struct `BBMOD_Class`, macro `BBMOD_CLASS_GENERATED_BODY` and functions `bbmod_is_class` and `bbmod_class_get_name`! This means methods `is_instance`, `implement` and `implements` are also no longer available. Please make sure that you are not using any of these before upgrading to this version!
* Added `BBMOD_IDestructible`, which is an interface for structs that need to be manually destroyed to properly free used memory. Structs that previously inherited from `BBMOD_Class` and still need a `destroy` method now implement this interface. Structs that did not need the method but still had it, because they inherited from `BBMOD_Class`, now do not have the method and trying to call it will give you an error. To fix this, simply remove these calls.

* Optimized method `BBMOD_MaterialPropertyBlock.apply`, which was previously slowed down by using function `variable_struct_get_names`.

* Added new render command `BBMOD_ERenderCommand.SetGpuState`, which sets the GPU state.
* Added new method `BBMOD_RenderQueue.SetGpuState(_state)`, which adds a `BBMOD_ERenderCommand.SetGpuState` command into the queue.
* Added new render command `BBMOD_ERenderCommand.SubmitRenderQueue`, which submits another render queue.
* Added new method `BBMOD_RenderQueue.SubmitRenderQueue(_renderQueue)`, which adds a `BBMOD_ERenderCommand.SubmitRenderQueue` command into the queue.

* Fixed gizmo, which still did not work in 3.17.0.

* Fixed methods `DrawSpriteExt`, `DrawSpriteGeneral` and `DrawSpritePart` of `BBMOD_RenderQueue` crashing because of wrong variable names.
