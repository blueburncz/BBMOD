# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Added new enum `BBMOD_EShaderUniformType`, which is an enumeration of shader uniform types.
* Added new struct `BBMOD_MaterialPropertyBlock`, which is a collection of material properties. Useful in case you want to use the same material when rendering multiple models and only change some of its properties for each model.
* Added new function `bbmod_material_props_set`, using which you can set the current material property block.
* Added new function `bbmod_material_props_get`, using which you can retrieve the current material property block.
* Added new function `bbmod_material_props_reset`, using which you can unset the current material property block.
* Added new member `ApplyMaterialProps` to enum `BBMOD_ERenderCommand`, which is a render command to apply a material property block.
* Added new member `SetMaterialProps` to enum `BBMOD_ERenderCommand`, which is a render command to set current material property block.
* Added new member `ResetMaterialProps` to enum `BBMOD_ERenderCommand`, which is a render command to reset current material property block.
* Added new method `apply_material_props` to struct `BBMOD_RenderQueue`, which adds a `BBMOD_ERenderCommand.ApplyMaterialProps` command into the queue.
* Added new method `set_material_props` to struct `BBMOD_RenderQueue`, which adds a `BBMOD_ERenderCommand.SetMaterialProps` command into the queue.
* Added new method `reset_material_props` to struct `BBMOD_RenderQueue`, which adds a `BBMOD_ERenderCommand.ResetMaterialProps` command into the queue.
* Added new method `Negate` to structs `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4`, which negates the vector and returns the result as a new vector.
* Added new macro `BBMOD_MAX_PUNCTUAL_LIGHTS`, which is the maximum number of punctual lights in shaders. Equals to 8.
* Property `BBMOD_BaseShader.MaxPunctualLights` is now read-only and deprecated. Please use the new macro `BBMOD_MAX_PUNCTUAL_LIGHTS` instead.
* Fixed methods `world_to_screen` and `screen_point_to_vec3` of `BBMOD_BaseCamera`, which returned coordinates mirrored on the Y axis on some platforms.
* Fixed `BBMOD_Cubemap` contents being flipped vertically on Windows.
* Fixed crash in `bbmod_instance_to_buffer` when saving `BBMOD_EPropertyType.RealArray` properties.
* Fixed gizmo, which did not work after update 3.16.8.
