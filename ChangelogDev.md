# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Moved properties `EnableSSAO`, `SSAOScale`, `SSAORadius`, `SSAOPower`, `SSAOAngleBias`, `SSAODepthRange`, `SSAOSelfOcclusionBias` and `SSAOBlurDepthRange` from `BBMOD_DefaultRenderer` to `BBMOD_BaseRenderer`.
* `BBMOD_PointLight` can now also cast shadows.
* Added new property `Frameskip` to `BBMOD_Light`, which is the number of frames to skip between individual updates of the light's shadowmap.
* Added new property `Static` to `BBMOD_Light`, which when set to `true`, the light's shadowmap is captured only once.
* Added new property `NeedsUpdate` to `BBMOD_Light`, which if `true`, then the light's shadowmap needs to be updated.
* Added new function `bbmod_hdr_is_supported`, which checks whether high dynamic range (HDR) rendering is supported on the current platform.
* Added new macro `BBMOD_U_HDR`, which is the name of a fragment shader uniform of type `float` that holds whether HDR rendering is enabled (1.0) or not (0.0).
* Fixed function `bbmod_mrt_is_supported` not working on Mac.
* Fixed method `clone` of `BBMOD_TerrainMaterial`, which returned instances of `BBMOD_BaseMaterial`.
* Fixed materials with `AlphaBlend` enabled not working in the `Id` render pass.

* Method `set_texture_offset` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_texture_offset` instead.
* Method `set_texture_scale` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_texture_scale` instead.
* Method `set_bones` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_bones` instead.
* Method `set_batch_data` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_batch_data` instead.
* Method `set_alpha_test` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_alpha_test` instead.
* Method `set_cam_pos` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_cam_pos` instead.
* Method `set_exposure` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_exposure` instead.
* Method `set_set_instance_id` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_instance_id` instead.
* Method `set_set_material_index` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_material_index` instead.
* Method `set_set_ibl` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_ibl` instead.
* Method `set_ambient_light` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_ambient_light` instead.
* Method `set_directional_light` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_directional_light` instead.
* Method `set_punctual_lights` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_punctual_lights` instead.
* Method `set_fog` of `BBMOD_BaseShader` is now deprecated. Please use the new function `bbmod_shader_set_fog` instead.
* Method `set_normal_smoothness` of `BBMOD_DefaultShader` is now deprecated. Please use the new function `bbmod_shader_set_normal_smoothness` instead.
* Method `set_specular_color` of `BBMOD_DefaultShader` is now deprecated. Please use the new function `bbmod_shader_set_specular_color` instead.
* Method `set_normal_roughness` of `BBMOD_DefaultShader` is now deprecated. Please use the new function `bbmod_shader_set_normal_roughness` instead.
* Method `set_metallic_ao` of `BBMOD_DefaultShader` is now deprecated. Please use the new function `bbmod_shader_set_metallic_ao` instead.
* Method `set_subsurface` of `BBMOD_DefaultShader` is now deprecated. Please use the new function `bbmod_shader_set_subsurface` instead.
* Method `set_emissive` of `BBMOD_DefaultShader` is now deprecated. Please use the new function `bbmod_shader_set_emissive` instead.
* Method `set_lightmap` of `BBMOD_DefaultLightmapShader` is now deprecated. Please use the new function `bbmod_shader_set_lightmap` instead.
