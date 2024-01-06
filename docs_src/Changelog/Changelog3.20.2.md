# Changelog 3.20.2

* Added new interface `BBMOD_IMaterial`, which is an interface for the most basic BBMOD materials that can be used with the `BBMOD_Model.submit` method.
* Fixed method `set_pre_transform` of `BBMOD_DLL`, which accidentally controlled the "apply scale" option instead.
* Added new function `bbmod_shader_set_globals`, which passes all global uniforms to given shader.
