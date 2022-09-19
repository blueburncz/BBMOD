# Changelog 3.12.0
This update mainly adds support for loading materials from `*.bbmat` files. BBMAT is a simple JSON file containing material definition. It can be either created by hand or exported from [BBMOD GUI](https://blueburn.cz/index.php?menu=bbmod_gui).

## General:
* **Disabled** color grading on GLSL ES platforms, as it did not work consistently across various devices! This may be addressed in future versions.
* Fixed terrain not casting shadows.
* BBANIM files can now contain animation events.

## CLI:
* **Updated** Assimp from v5.2.4 to v5.2.5. This release for example fixes vertex weight issues, which in some cases lead into model deformations. You can find the full changelog [here](https://github.com/assimp/assimp/releases/tag/v5.2.5).

## GML API:
### Core module:
* Added function `bbmod_string_starts_with`, which checks whether a string starts with a substring.
* Added function `bbmod_string_split_on_first`, which splits the string in two at the first occurrence of the delimiter.
* Added function `bbmod_string_explode`, which splits given string on every occurrence of given character and puts created parts into an array.
* Added function `bbmod_string_join_array`, which joins an array into a string, putting separator in between each entry.
* Added function `bbmod_path_normalize`, which normalizes path for the current platform.
* Added function `bbmod_path_is_relative`, which checks if a path is relative.
* Added function `bbmod_path_is_absolute`, which checks if a path is absolute.
* Added function `bbmod_path_get_relative`, which retrieves a relative version of a path.
* Added function `bbmod_path_get_absolute`, which retrieves an absolute version of a path.
* Added function `bbmod_json_load` using which you can load a JSON file.
* Added function `bbmod_render_queues_get`, using which you can retrieve a read-only array of existing render queues.
* Variable `global.bbmod_render_queues` is now **obsolete**. Please use the new `bbmod_render_queues_get` instead.
* Added function `bbmod_render_pass_to_string`, which retrieves a name of a render pass.
* Added function `bbmod_render_pass_from_string`, which retrieves a render pass from its name.
* Added function `bbmod_shader_register`, using which you can register a shader under a name.
* Added function `bbmod_shader_exists`, using which you can check if there is a shader registered under given name.
* Added function `bbmod_shader_get`, using which you can retrieve registered shaders.
* Added function `bbmod_material_register`, using which you can register a material under a name.
* Added function `bbmod_material_exists`, using which you can check if there is a material registered under given name.
* Added function `bbmod_material_get`, using which you can retrieve registered materials.
* Added method `to_buffer` to `BBMOD_Resource`, using which you can write a resource into a buffer.
* Implemented method `to_buffer` for resources `BBMOD_Model`, `BBMOD_Animation` and `BBMOD_Sprite`.
* Added method `to_file` to `BBMOD_Resource`, using which you can write a resource into a file.
* Added method `to_json` to `BBMOD_Material`, using which you can save material properties to a JSON object.
* Added method `from_json` to `BBMOD_Material`, using which you can load material properties from a JSON object.
* Implemented methods `to_file`, `from_file` and `from_file_async` for `BBMOD_Material`.

### Resource Manager module:
* Method `load` of `BBMOD_ResourceManager` can now load materials from `*.bbmat` files.
