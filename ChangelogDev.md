# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Disabled color grading on GLSL ES platforms, as it did not work consistently across various devices. This may be addressed in future versions.
* Fixed terrain not casting shadows.
* Added method `to_buffer` to `BBMOD_Resource`, using which you can write a resource into a buffer.
* Implemented method `to_buffer` for resources `BBMOD_Model`, `BBMOD_Animation` and `BBMOD_Sprite`.
* Added method `to_file` to `BBMOD_Resource`, using which you can write a resource into a file.
* Increased minor version of the BBMOD file format to 4.
* `*.bbanim` files can now contain animation events.
* Added method `to_json` to `BBMOD_Material`, using which you can save material properties to a JSON object.
* Added method `from_json` to `BBMOD_Material`, using which you can load material properties from a JSON object.
* Implemented methods `to_file`, `from_file` and `from_file_async` for `BBMOD_Material`.
* Added function `bbmod_json_load` using which you can load a JSON file.
* Added function `bbmod_material_register`, using which you can register a material under a name.
* Added function `bbmod_material_exists`, using which you can check if there is a material registered under given name.
* Added function `bbmod_material_get`, using which you can retrieve registered materials.
* Method `load` of `BBMOD_ResourceManager` can now load materials from `*.bbmat` files.
* Added function `bbmod_render_queues_get`, using which you can retrieve a read-only array of existing render queues.
* Variable `global.bbmod_render_queues` is now obsolete. Please use the new `bbmod_render_queues_get` instead.
