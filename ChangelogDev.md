# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Added new method `Negate` to structs `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4`, which negates the vector and returns the result as a new vector.
* Added new macro `BBMOD_MAX_PUNCTUAL_LIGHTS`, which is the maximum number of punctual lights in shaders. Equals to 8.
* Property `BBMOD_BaseShader.MaxPunctualLights` is now read-only and deprecated. Please use the new macro `BBMOD_MAX_PUNCTUAL_LIGHTS` instead.
* Fixed methods `world_to_screen` and `screen_point_to_vec3` of `BBMOD_BaseCamera`, which returned coordinates mirrored on the Y axis on some platforms.
* Fixed `BBMOD_Cubemap` contents being flipped vertically on Windows.
* Fixed crash in `bbmod_instance_to_buffer` when saving `BBMOD_EPropertyType.RealArray` properties.
* Fixed gizmo, which did not work after update 3.16.8.
