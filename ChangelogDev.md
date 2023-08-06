# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Added new option `--export-materials` (`-em`) to BBMOD CLI, using which you can enable/disable export of materials to `.bbmat` files. This is an **experimental** feature and it is by default **disabled**!
* Added new method `get_export_materials` to struct `BBMOD_DLL`, which checks whether export of materials is enabled.
* Added new method `set_export_materials` to struct `BBMOD_DLL`, which enables/disables export of materials.
* Added new option `-zup` to BBMOD_CLI, using which you can enable/disable conversion from Y-up to Z-up. This is an **experimental** feature an it is by default **disabled**!
* Added new method `get_zup` to struct `BBMOD_DLL`, which checks whether model is converted from Y-up to Z-up.
* Added new method `set_zup` to struct `BBMOD_DLL`, which enables/disables conversion from Y-up to Z-up.
* Added new option `--enable-prefix` to BBMOD CLI, using which you can enable/disable prefixing of output files with model name. This is by default **enabled** for backwards compatibility.
* Added new method `get_enable_prefix` to struct `BBMOD_DLL`, which checks whether prefixing of output files with model name is enabled.
* Added new method `set_enable_prefix` to struct `BBMOD_DLL`, which enables/disables prefixing of output files with model name.
* Fixed a bug where BBMOD CLI used directory name as the model name if it was given an output directory instead of an output filename.
* BBMOD CLI now accepts directories as an input, in which case it converts all files within the directory into the output directory.
* Added new macro `BBMOD_VFORMAT_DEFAULT_COLOR`, which is the default vertex format for static models with vertex colors.
* Added new macro `BBMOD_VFORMAT_DEFAULT_COLOR_ANIMATED`, which is the default vertex format for animated models with vertex colors.
* Added new macro `BBMOD_VFORMAT_DEFAULT_COLOR_BATCHED`, which is the default vertex format for dynamically batched models with vertex colors.
* Added shader variations for meshes with vertex colors.
* Fixed property `BaseOpacityMultiplier` of `BBMOD_BaseMaterial` not being converted from gamma space to linear space in shaders.
* Fixed docs for arguments of method `DrawDebug` of structs `BBMOD_Collider` and `BBMOD_Ray` (argument `_alpha` was missing).
* Added new property `ImportMaterials` to struct `BBMOD_OBJImporter`. If it is set to `true`, the importer tries to import materials from `*.mtl` files. Default value is `false`.
* Added new function `bbmod_mipenable_to_string`, which converts constants `mip_off`, `mip_on` and `mip_markedonly` to a string.
* Added new function `bbmod_mipenable_from_string`, which converts strings "mip_off", "mip_on" and "mip_markedonly" to the respective constants.
* Added new function `bbmod_texfilter_to_string`, which converts constants `tf_point`, `tf_linear` and `tf_anisotropic` to a string.
* Added new function `bbmod_texfilter_from_string`, which converts strings "tf_point", "tf_linear" and "tf_anisotropic" to the respective constants.
