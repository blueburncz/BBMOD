# Changelog 3.8.0
This release mainly unifies default and PBR shaders and materials by merging them into one and supporting features from both. This means you can now use the default shaders and materials with both specular color & smoothness and metallic & roughness workflows. The default shaders and materials now also support emissive and subsurface textures. All contents of the PBR submodule are now obsolete and they will be removed in a future release. Please use the default ones instead. Shaders used for rendering gizmos were accidentally changed in the last release, so these have been fixed. Further fixes of model rendering on some Android devices are also included in this release.

## GML API:
### Core module:
* Moved properties `NormalRoughness`, `MetallicAO`, `Subsurface` and `Emissive` and methods `set_normal_roughness`, `set_metallic_ao`, `set_subsurface` and `set_emissive` from struct `BBMOD_PBRMaterial` to struct `BBMOD_DefaultMaterial`.
* Moved methods `set_normal_roughness`, `set_metallic_ao`, `set_subsurface` and `set_emissive` from struct `BBMOD_PBRShader` to struct `BBMOD_DefaultShader`.

### Rendering module:
#### PBR submodule:
* Struct `BBMOD_PBRMaterial` now inherits from `BBMOD_DefaultMaterial`.
* Struct `BBMOD_PBRMaterial` is now obsolete, please use `BBMOD_DefaultMaterial` instead.
* Struct `BBMOD_PBRShader` now inherits from `BBMOD_DefaultShader`.
* Struct `BBMOD_PBRShader` is now obsolete, please use `BBMOD_DefaultShader` instead.
* Macro `BBMOD_SHADER_PBR` is now obsolete, please use `BBMOD_SHADER_DEFAULT` instead.
* Macro `BBMOD_SHADER_PBR_ANIMATED` is now obsolete, please use `BBMOD_SHADER_DEFAULT_ANIMATED` instead.
* Macro `BBMOD_SHADER_PBR_BATCHED` is now obsolete, please use `BBMOD_SHADER_DEFAULT_BATCHED` instead.
* Macro `BBMOD_MATERIAL_PBR` is now obsolete, please use `BBMOD_MATERIAL_DEFAULT` instead.
* Macro `BBMOD_MATERIAL_PBR_ANIMATED` is now obsolete, please use `BBMOD_MATERIAL_DEFAULT_ANIMATED` instead.
* Macro `BBMOD_MATERIAL_PBR_BATCHED` is now obsolete, please use `BBMOD_MATERIAL_DEFAULT_BATCHED` instead.
* Added new macros `BBMOD_ShPBR`, `BBMOD_ShPBRAnimated` and `BBMOD_ShPBRBatched` for backwards compatibility purposes. These evaluate to `BBMOD_ShDefault`, `BBMOD_ShDefaultAnimated` and `BBMOD_ShDefaultBatched` respectively.

#### Sky submodule:
* Moved macro `BBMOD_MATERIAL_SKY` from the PBR submodule into a new Sky submodule, since the PBR submodule is going to be removed in a future release.
