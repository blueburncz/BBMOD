# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Fixed methods `world_to_screen` and `screen_point_to_vec3` of `BBMOD_BaseCamera`, which returned coordinates mirrored on the Y axis on some platforms.
* Fixed `BBMOD_Cubemap` contents being flipped vertically on Windows.
