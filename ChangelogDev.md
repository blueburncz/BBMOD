# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Fixed strength of lens flares exceeding 1 when property `Range` is not `infinity`.
* Fixed macro `BBMOD_RELEASE_PATCH`, which we forgot to increase the last release.
* Fixed macro `BBMOD_RELEASE_STRING`, which used invalid syntax.
* Fixed method `set_material` of `BBMOD_DefaultSpriteShader`, which set material UVs incorrectly.
* Added more ready-to-use models of basic shapes.
* Fixed method `clear` of `BBMOD_ResourceManager` not always removing destroyed resources, which could cause crashes for example when restarting rooms.
* Shaders `BBMOD_SHADER_DEFAULT_DEPTH` and `BBMOD_SHADER_GBUFFER` are now compatible with vertex format `BBMOD_VFORMAT_DEFAULT_SPRITE`.
* Added new macro `BBMOD_U_SUBSURFACE_UV`, which is the name of a fragment shader uniform of type `vec4` that holds top left and bottom right coordinates of the subsurface texture on its texture page.
* Added new function `bbmod_shader_set_subsurface_uv`, which sets the `BBMOD_U_SUBSURFACE_UV` uniform to given values.
* Added new macro `BBMOD_U_EMISSIVE_UV`, which is the name of a fragment shader uniform of type `vec4` that holds top left and bottom right coordinates of the emissive texture on its texture page.
* Added new function `bbmod_shader_set_emissive_uv`, which sets the `BBMOD_U_EMISSIVE_UV` uniform to given values.
* Fixed property `RenderScale` of renderers affecting the size of the final surface on screen.
