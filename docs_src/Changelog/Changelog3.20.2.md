# Changelog 3.20.2

* Added new interface `BBMOD_IMaterial`, which is an interface for the most basic BBMOD materials that can be used with the `BBMOD_Model.submit` method.
* Fixed method `set_pre_transform` of `BBMOD_DLL`, which accidentally controlled the "apply scale" option instead.
* Method `BBMOD_Material.from_json` now supports `undefined` and string "undefined" for shaders, in which case it removes a shader for given render pass.
* Added new function `bbmod_shader_set_globals`, which passes all global uniforms to given shader.
* Fixed disabling texture filtering via `BBMOD_Material.Filtering` not working.
* Argument `_sha1` of method `BBMOD_ResourceManager.load` can now be skipped instead of set to `undefined` if you do not wish to do a SHA1 check.
* Added new macro `BBMOD_MATRIX_IDENTITY`, which is a read-only globally allocated identity matrix.
* Reflection probes are now captured in HDR if supported by the target platform.
* Added new property `Infinite` to `BBMOD_ReflectionProbe`. When set to `true` then the reflection probe has infinite extents, otherwise they are defined by the `Size` property. Default value is `false`.
* Added new function `bbmod_render_queues_submit([_instances])`, which submits all existing render queues.
* Added new function `bbmod_render_queues_clear()`, which clears all existing render queues.
  