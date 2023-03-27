# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Added an optional argument `_format` to function `bbmod_surface_check`, which is the surface format to use when the surface is created.
* Added new property `Format` to `BBMOD_Cubemap`, which is the format of created surfaces. Default value is `surface_rgba8unorm`.
* Added new property `SurfaceOctahedron` to `BBMOD_Cubemap`, which is a surface with the cubemap converted into an octahedral map.
* Arguments of `_clearColor` and `_clearAlpha` of method `BBMOD_Cubemap.to_single_surface` are now optional and they default to `c_black` and 1 respectively.
* Added new method `to_octahedron` to `BBMOD_Cubemap`, which converts the cubemap to an octahedral map.
