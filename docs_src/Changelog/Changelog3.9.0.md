# Changelog 3.9.0
This release adds support for rendering models with baked lightmaps using
secondary UV channel. Additionally fix of specular highlights intensity when
using specular color textures is also included in this release.

## BBMOD CLI:
* Added new option `--disable-uv2` (`-duv2`), using which you can disable export of second UV channel (if defined). This option is `true` by default (second UV channel is disabled).
* The `_log.txt` file created during model conversion now describes vertex format of each mesh.

## GML API:
### Core module:
* The first argument of `BBMOD_VertexFormat`'s constructor can now be a struct with keys called after properties of `BBMOD_VertexFormat` and values `true` or `false`, depending on whether the vertex format should or should not have the property.
* Added new property `TextureCoords2` to struct `BBMOD_VertexFormat`, which tells whether the vertex format has a second UV channel.
* Added optional argument `_versionMinor` to `bbmod_vertex_format_load`, which is the minor version of a BBMOD file that the vertex format is being loaded from.
* Added new functions `bbmod_light_ambient_get_affect_lightmaps` and `bbmod_light_ambient_set_affect_lightmaps`, using which you can get/set whether the ambient light affects materials that use baked lightmaps. By default this is enabled.
* Added new property `AffectLightmaps` to struct `BBMOD_Light`, using which you can enable/disable the light for materials that use baked lightmaps. By default this is enabled.

### DLL module:
* Added new property `get_disable_uv2` to struct `BBMOD_DLL`, using which you can check whether second UV channel is disabled.
* Added new property `set_disable_uv2` to struct `BBMOD_DLL`, using which you can enable/disable second UV channel.

### Lightmap module:
* Added new module - Lightmap.
* Added new struct `BBMOD_LightmapShader`, which is a wrapper for shaders used by lightmapped materials.
* Added new struct `BBMOD_LightmapMaterial`, which is a material that can be used when rendering models with two UV channels, the second one being used for lightmaps.
* Added new macro `BBMOD_VFORMAT_LIGHTMAP`, which is a vertex format of models with two UV channels, the second one being used for lightmaps.
* Added new macro `BBMOD_SHADER_LIGHTMAP`, which is a shader for rendering models with two UV channels, the second one being used for lightmaps.
* Added new macro `BBMOD_MATERIAL_LIGHTMAP`, which is a material for models with two UV channels, the second one being used for lightmaps.
* Added new functions `bbmod_lightmap_get` and `bbmod_lightmap_set`, using which you can get/set the default lightmap texture used by all lightmapped materials (unless they override it).
