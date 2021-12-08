# Changelog 3.1.2
This release mainly adds possibility to define shaders used by a material in individual render passes, which in combination with render queues enables creating advanced rendering pipelines.

## GML API:
### Core module:
* Added new macro `BBMOD_RGBM_VALUE_MAX`, which defines the maximum value which a single color channel can have before it is converted to RGBM.
* Added new struct `BBMOD_Color`, which supports HDR colors.
* Added new struct `BBMOD_BaseShader`, which does not define any uniforms specific to BBMOD and it is now the base class for shader resource wrappers.
* Struct `BBMOD_Shader` now inherits from `BBMOD_BaseShader`.
* Added new enum of render passes `BBMOD_ERenderPass`.
* Deprecated macros `BBMOD_RENDER_DEFERRED`, `BBMOD_RENDER_FORWARD` and `BBMOD_RENDER_SHADOWS`. Use appropriate members of `BBMOD_ERenderPass` instead, as these macros will be removed in a future release.
* Removed property `Shader` of `BBMOD_Material`.
* Added new methods `set_shader`, `has_shader`, `get_shader` and `remove_shader` to `BBMOD_Material`, using which you can define shaders used by the material in specific render passes.
* Method `BBMOD_Material.apply` now returns `true` or `false` based on whether the material was applied (instead of always returning `self`).
* Method `BBMOD_Material.submit_queue` does no longer automatically clear the queue.
* Added new method `BBMOD_Material.clear_queue`, which clears the material's render queue.
* New `BBMOD_Material`s no longer use the checkerboard texture as the default. The texture is still used by `BBMOD_MATERIAL_DEFAULT*` materials.
* Function `bbmod_get_materials` now accepts an optional render pass argument, using which you can retrieve only materials that have a shader for a specific render pass.
* Added new interface `BBMOD_IRenderTarget`, which is an interface for structs that can be set as a render target.
* Added new methods `Set` and `SetIndex` to `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4` using which you can change the vector components in-place.
* Moved `bbmod_set_camera_position`, `global.bbmod_camera_exposure`, `global.bbmod_camera_position` from the PBR module to the Core module to resolve dependency issues.
* Added new function `bbmod_get_calling_function_name`, using which you can retrieve the name of the function that calls it.
* Added new function `bbmod_class_get_name`, using which you can retrieve class names of structs inheriting from `BBMOD_Class`.
* Added new macro `BBMOD_CLASS_GENERATED_BODY`, which now must always be the first line in structs inheriting from `BBMOD_Class`.
* Added new method `BBMOD_Class.is_instance`, using which you can test if an instance of `BBMOD_Class` inherits from a specific class.

### Importer module:
* Fixed import of OBJ model that included empty lines.

### Rendering module:
* Added new module - Rendering.

#### Cubemap submodule:
* Added new submodule - Cubemap.
* Added new struct `BBMOD_Cubemap`, using which you can easily render scenes into a cubemap.

#### PBR submodule:
* PBR is now a submodule of the Rendering module.
* Parameter `_shader` in the constructor of `BBMOD_PBRMaterial` is now optional.
* Method `BBMOD_PBRMaterial.set_emissive` now accepts `BBMOD_Color` as an argument. The variant with 3 arguments (one for each color channel) is kept for backwards compatibility, but it should not be used anymore, as it will be removed in a future release!

#### Renderer submodule:
* Renderer is now a submodule of the Rendering module.
