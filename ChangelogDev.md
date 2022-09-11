# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Fixed terrain not casting shadows.
* Added method `to_buffer` to `BBMOD_Resource`, using which you can write a resource into a buffer.
* Implemented method `to_buffer` for resources `BBMOD_Model`, `BBMOD_Animation` and `BBMOD_Sprite`.
* Added method `to_file` to `BBMOD_Resource`, using which you can write a resource into a file.
* Increased minor version of the BBMOD file format to 4.
* `*.bbanim` files can now contain animation events.
* Added method `to_json` to `BBMOD_Material`, using which you can save material properties to a JSON object.
* Added method `from_json` to `BBMOD_Material`, using which you can load material properties from a JSON object.
* Implemented methods `to_file` and `from_file` for `BBMOD_Material`.
