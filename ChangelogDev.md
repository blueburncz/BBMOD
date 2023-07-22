# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Added new macro `BBMOD_VFORMAT_DEFAULT_COLOR`, which is the default vertex format for static models with vertex colors.
* Added new macro `BBMOD_VFORMAT_DEFAULT_COLOR_ANIMATED`, which is the default vertex format for animated models with vertex colors.
* Added new macro `BBMOD_VFORMAT_DEFAULT_COLOR_BATCHED`, which is the default vertex format for dynamically batched models with vertex colors.
* Added shader variations for meshes with vertex colors.
* Added new option `--export-materials` (`-em`) to BBMOD CLI, using which you can enable/disable export of materials to `.bbmat` files. This is an **experimental** feature and it is by default **disabled**!
* Added new method `get_export_materials` to struct `BBMOD_DLL`, which checks whether export of materials is enabled.
* Added new method `set_export_materials` to struct `BBMOD_DLL`, which enables/disables export of materials.
* Added new option `-zup` to BBMOD_CLI, using which you can enable/disable conversion from Y-up to Z-up. This is an **experimental** feature an it is by default **disabled**!
* Added new method `get_zup` to struct `BBMOD_DLL`, which checks whether model is converted from Y-up to Z-up.
* Added new method `set_zup` to struct `BBMOD_DLL`, which enables/disables conversion from Y-up to Z-up.
* Fixed property `BaseOpacityMultiplier` of `BBMOD_BaseMaterial` not being converted from gamma space to linear space in shaders.
* Fixed docs for arguments of method `DrawDebug` of structs `BBMOD_Collider` and `BBMOD_Ray` (argument `_alpha` was missing).
