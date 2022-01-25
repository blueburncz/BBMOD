# Changelog 3.1.7
This release mainly focuses on HTML5 support. It adds means for asynchronnous loading of BBMOD model and animations, as well as regular buffers and sprites, which is required for HTML5. Mouselook was also fixed using a JavaScript extension. Additionally there is now a new resource manager module, which greatly simplifies loading or resources, retrieval of already loaded resources and freeing of all loaded resources from memory. The demo project was also reworked into a minigame to show off these new features.

## GML API:
### Core module:
* Added new function `bbmod_buffer_load_async`, using which you can asynchronnously load buffer from a file.
* Added new function `bbmod_async_save_load_update`, which must be executed in the "Async - Save/Load" event if you use asynchronnous loading of buffers.
* Added new function `bbmod_sprite_add_async`, using which you can asynchronnously load sprite from a file.
* Added new function `bbmod_async_image_loaded_update`, which must be executed in the "Async - Image Loaded" event if you use asynchronnous loading of sprites.
* Added new function `bbmod_empty_callback`, which is an empty callback for asynchronnous functions.
* Added new struct `BBMOD_Resource`, which is now the base struct for all BBMOD resources. This struct contains methods `from_file` and `from_file_async`, using which you can load resources from file synchronnously or asynchronnously. When using asynchronnous loading, property `IsLoaded` is `false` until the resource is loaded. Asynchronnous loading of files is required for example on the HTML5 platform.
* Added new struct `BBMOD_Sprite`, which is a sprite resource.
* Structs `BBMOD_Model` and `BBMOD_Animation` now inherit from `BBMOD_Resource`.
* Struct `BBMOD_BaseMaterial` now inherits from `BBOMD_Resource` too, though it does not yet support loading from files/buffers.
* Arguments of the `BBMOD_Model` constructor are now optional.
* Fixed method `BBMOD_VertexFormat.get_byte_size`, which returned incorrect values when the vertex format included vertex colors or bones.
* Fixed creating dynamic and static batches with models that have vertex colors.

### Camera module:
* Fixed mouselook on HTML5.
* Fixed audio listener orientation.

### Resource manager module:
* Added new module - Resource manager.
* Added new struct `BBMOD_ResourceManager`, using which you can load any BBMOD resource. These are automatically destroyed when the resource manager is destroyed.

### Rendering module:
#### Renderer submodule:
* Added new property `VignetteColor` to `BBMOD_Renderer`, which is the color of the vignette effect.
* When a renderer with enabled `UseAppSurface` is destroyed, it again enables automatic rendering of the application surface.
