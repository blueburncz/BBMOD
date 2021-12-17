# Changelog 3.1.4
This release brings an upgrade to the default shaders, which now support the specular color-smoothness workflow, as well as dynamic shadows from the directional light. Some refactoring of materials and shaders inheritance was required to enable this. If you only used the default materials (`BBMOD_MATERIAL_DEFAULT*`), then this change should not affect your project at all. If you have created your own materials, please read the following changelog thoroughly to be able to update your code.

## GML API:
### Core module:
* Renamed `BBMOD_Material` to `BBMOD_DefaultMaterial`.
* Method `BBMOD_BaseMaterial.set_base_opacity` now takes `BBMOD_Color` as an argument. The variant with separate arguments for color and opacity is kept for compatibility purposes, but it should not be used anymore, as it will be removed in a future release!
* Added new property `BBMOD_DefaultMaterial.NormalSmoothness`, which is a texture with tangent-space normal vector in the RGB channels and smoothness in the A channel.
* Added new method `BBMOD_DefaultMaterial.set_normal_smoothness`, using which you can set the normal vector and smoothness to a uniform value for the entire material.
* Added new property `BBMOD_DefaultMaterial.SpecularColor`, which is a texture with specular color in the RGB channels.
* Added new method `BBMOD_DefaultMaterial.set_specular_color`, using which you can set the specular color to a uniform value for the entire material.
* Renamed `BBMOD_Shader` to `BBMOD_DefaultShader`.
* Added method `BBMOD_DefaultShader.set_normal_smoothness`, using which you can set the `bbmod_NormalSmoothness` texture sampler.
* Added method `BBMOD_DefaultShader.set_specular_color`, using which you can set the `bbmod_SpecularColor` texture sampler.
* Added method `BBMOD_DefaultShader.set_shadowmap`, which is used to set uniforms `bbmod_ShadowmapEnable`, `bbmod_Shadowmap`, `bbmod_ShadowmapMatrix`,`bbmod_ShadowmapArea` and `bbmod_ShadowmapNormalOffset` required for shadow mapping.
* Added new struct `BBMOD_Shader`, which is now the base class for wrappers of raw GameMaker shader resources.
* Struct `BBMOD_BaseShader` is now base class for shaders with BBMOD-specific code. General-purpose code was moved to `BBMOD_Shader`.
* Added new functions `bbmod_camera_get_zfar` and `bbmod_camera_set_zfar`, using which you can configure the distance to the far clipping plane passed to shaders.
* Added new method `BBMOD_BaseShader.set_zfar`, which is used to set uniform `bbmod_ZFar`.
* Added new property `Enabled` to `BBMOD_Light`, using which you can enable/disable lights without having to call appropriate set/add/remove functions.
* Added new member `BBMOD_ERenderPass.Id`, which is a render pass during which can instance IDs be rendered into an off-screen surface.
* Fixed `BBMOD_Animation.create_transition`, which did not round transition duration, causing errors in animation playback.
* Fixed method `BBMOD_Color.Mix`, which used inexistent variable name.

### Rendering module:
* Added new submodule - Depth buffer - which contains shaders for rendering scene depth.

#### Depth buffer submodule:
* Added new macros `BBMOD_SHADER_DEPTH`, `BBMOD_SHADER_DEPTH_ANIMATED` and `BBMOD_SHADER_DEPTH_BATCHED`, which are shaders used when rendering scene depth.

#### Renderer submodule:
* Added new property `BBMOD_Renderer.EnableShadows`, using which you can enable rendering of dynamic shadows. Only materials with a shader defined for `BBMOD_ERenderPass.Shadows` render pass can cast shadows!
* Added new property `BBMOD_Renderer.ShadowmapArea`, which is an area around the camera captured by the shadowmap. Only models within this area will cast shadows.
* Added new property `BBMOD_Renderer.ShadowmapResolution`, which is the resolution of the shadowmap. Must be power of 2.
* Added new property `BBMOD_Renderer.ShadowmapNormalOffset`, which is used to offset vertices by their normal vector when sampling the shadowmap. Configure this value to remove artifacts.
