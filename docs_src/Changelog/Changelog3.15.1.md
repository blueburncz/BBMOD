# Changelog 3.15.1
This is a tiny release that adds more mipmapping configuration options to materials.

## Core module:
* Added new property `MipBias` to `BBMOD_Material`, which defines a bias for which mip level is used. Default value is 0.
* Added new property `MipFilter` to `BBMOD_Material`, which is the mip filter mode used for the material. Default value is `tf_anisotropic`.
* Added new property `MipMin` to `BBMOD_Material`, which is the minimum mip level used. Default value is 0.
* Added new property `MipMax` to `BBMOD_Material`, which is the maximum mip level used. Default value is 16.
* Added new property `Anisotropy` to `BBMOD_Material`, which is the maximum level of anisotropy when `BBMOD_Material.MipFilter` is set to `tf_anisotropic`. Default value is 16.
