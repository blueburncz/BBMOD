# Changelog 3.19.3
This is a small patch release that fixes Gizmo on Windows.

* Fixed shader `BBMOD_SHADER_INSTANCE_ID` not working on Windows due to an invalid vertex format defined in a shader.
* Fixed shader `BBMOD_SHADER_INSTANCE_ID` not having variants for vertex formats `BBMOD_VFORMAT_DEFAULT_COLOR`, `BBMOD_VFORMAT_DEFAULT_COLOR_ANIMATED`, `BBMOD_VFORMAT_DEFAULT_COLOR_BATCHED`.
