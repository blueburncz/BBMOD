# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Fixed `BBMOD_Cubemap` contents being flipped vertically on Windows.
* Added an optional argument `_format` to function `bbmod_surface_check`, which is the surface format to use when the surface is created.
* Added new property `Format` to `BBMOD_Cubemap`, which is the format of created surfaces. Default value is `surface_rgba8unorm`.
* Added new property `SurfaceOctahedron` to `BBMOD_Cubemap`, which is a surface with the cubemap converted into an octahedral map.
* Arguments of `_clearColor` and `_clearAlpha` of method `BBMOD_Cubemap.to_single_surface` are now optional and they default to `c_black` and 1 respectively.
* Added new method `to_octahedron` to `BBMOD_Cubemap`, which converts the cubemap to an octahedral map.
* Fixed methods `world_to_screen` and `screen_point_to_vec3` of `BBMOD_BaseCamera`, which returned coordinates mirrored on the Y axis on some platforms.
* Fixed `BBMOD_Cubemap` contents being flipped vertically on Windows.
* Fixed crash in `bbmod_instance_to_buffer` when saving `BBMOD_EPropertyType.RealArray` properties.
* Fixed gizmo, which couldn't be clicked on after update 3.16.8.


* Added new struct `BBMOD_ReflectionProbe`
* Added new function `bbmod_reflection_probe_add`
* Added new function `bbmod_reflection_probe_count`
* Added new function `bbmod_reflection_probe_get`
* Added new function `bbmod_reflection_probe_remove`
* Added new function `bbmod_reflection_probe_remove_index`
* Added new function `bbmod_reflection_probe_clear`
* Added `ReflectionProbe` to `BBMOD_ERenderPass`
* Added new method `prefilter_ibl` to `BBMOD_Cubemap`
* Material `BBMOD_MATERIAL_SKY` now has a shader for the new `BBMOD_ERenderPass.ReflectionCapture` pass.
