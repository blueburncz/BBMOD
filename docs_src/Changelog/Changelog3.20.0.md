# Changelog 3.20.0
This release brings a new deferred rendering pipeline with support for unlimited number of shadow-casting lights. All light types, including point lights, can now cast shadows. Please note that the deferred renderer has specific hardware requirements and therefore it is not supported on all platforms! When deferred rendering is not available, you can still use the old default renderer, but that is still limited to maximum 8 punctual lights and only a single shadow-casting light. Additionally, you can now configure frame skip for capturing shadowmaps or mark a light as "static" to capture its shadowmap only once to increase performance.

* Added new struct `BBMOD_DeferredRenderer`, which is a deferred renderer with support for unlimited number of shadow-casting lights.
* Added new function `bbmod_deferred_renderer_is_supported`, which checks whether deferred renderer is supported on the current platform.
* Added new macro `BBMOD_SHADER_GBUFFER`, which is a shader for rendering models into the G-buffer.
* Added new macro `BBMOD_MATERIAL_DEFERRED`, which is an opaque material that can be used with the new `BBMOD_DeferredRenderer`.
* Added new macro `BBMOD_SHADER_TERRAIN_GBUFFER`, which is a shader for rendering terrain into the G-buffer. Supports 3 terrain layers at most!
* Added new macro `BBMOD_MATERIAL_TERRAIN_DEFERRED`, which is a terrain material that can be used with the new `BBMOD_DeferredRenderer`.
* Moved properties `EnableSSAO`, `SSAOScale`, `SSAORadius`, `SSAOPower`, `SSAOAngleBias`, `SSAODepthRange`, `SSAOSelfOcclusionBias` and `SSAOBlurDepthRange` from `BBMOD_DefaultRenderer` to `BBMOD_BaseRenderer`.
* `BBMOD_PointLight` can now also cast shadows.
* Added new property `Frameskip` to `BBMOD_Light`, which is the number of frames to skip between individual updates of the light's shadowmap.
* Added new property `Static` to `BBMOD_Light`, which when set to `true`, the light's shadowmap is captured only once.
* Added new property `NeedsUpdate` to `BBMOD_Light`, which if `true`, then the light's shadowmap needs to be updated.
* Added new member `Background` to enum `BBMOD_ERenderPass`, which is a render pass for background objects (e.g. skydome).
* Material `BBMOD_MATERIAL_SKY` now uses the `Background` render pass instead of `Forward`.
* Implemented the new `Background` render pass into `BBMOD_DefaultRenderer`.
* Added new macro `BBMOD_U_SHADOWMAP_NORMAL_OFFSET_VS`, which is the name of a vertex shader uniform of type `float` that holds how much are vertices offset by their normal before they are transformed into shadowmap-space, using formula `vertex + normal * normalOffset`.
* Added new macro `BBMOD_U_SHADOWMAP_NORMAL_OFFSET_PS`, which is the name of a fragment shader uniform of type `float` that holds how much are vertices offset by their normal before they are transformed into shadowmap-space, using formula `vertex + normal * normalOffset`.
* Macro `BBMOD_U_SHADOWMAP_NORMAL_OFFSET` is now **obsolete**! Please use the new `BBMOD_U_SHADOWMAP_NORMAL_OFFSET_VS` instead.
* Added new function `bbmod_hdr_is_supported`, which checks whether high dynamic range (HDR) rendering is supported on the current platform.
* Added new macro `BBMOD_U_HDR`, which is the name of a fragment shader uniform of type `float` that holds whether HDR rendering is enabled (1.0) or not (0.0).
* Added new function `bbmod_shader_set_normal_matrix`, which sets the `BBMOD_U_NORMAL_MATRIX` uniform.
* Added new function `bbmod_shader_set_texture_offset`, which sets the `BBMOD_U_TEXTURE_OFFSET` uniform.
* Added new function `bbmod_shader_set_texture_scale`, which sets the `BBMOD_U_TEXTURE_SCALE` uniform.
* Added new function `bbmod_shader_set_bones`, which sets the `BBMOD_U_BONES` uniform.
* Added new function `bbmod_shader_set_batch_data`, which sets the `BBMOD_U_BATCH_DATA` uniform.
* Added new function `bbmod_shader_set_instance_id`, which sets the `BBMOD_U_INSTANCE_ID` uniform.
* Added new function `bbmod_shader_set_material_index`, which sets the `BBMOD_U_MATERIAL_INDEX` uniform.
* Added new function `bbmod_shader_set_base_opacity_multiplier`, which sets the `BBMOD_U_BASE_OPACITY_MULTIPLIER` uniform.
* Added new function `bbmod_shader_set_normal_smoothness`, which sets uniforms `BBMOD_U_NORMAL_W` and `BBMOD_U_IS_ROUGHNESS`.
* Added new function `bbmod_shader_set_normal_roughness`, which sets uniforms `BBMOD_U_NORMAL_W` and `BBMOD_U_IS_ROUGHNESS`.
* Added new function `bbmod_shader_set_specular_color`, which sets uniforms `BBMOD_U_MATERIAL` and `BBMOD_U_IS_METALLIC`.
* Added new function `bbmod_shader_set_metallic_ao`, which sets uniforms `BBMOD_U_MATERIAL` and `BBMOD_U_IS_METALLIC`.
* Added new function `bbmod_shader_set_subsurface`, which sets the `BBMOD_U_SUBSURFACE` uniform.
* Added new function `bbmod_shader_set_emissive`, which sets the `BBMOD_U_EMISSIVE` uniform.
* Added new function `bbmod_shader_set_lightmap`, which sets the `BBMOD_U_LIGHTMAP` uniform.
* Added new function `bbmod_shader_set_base_opacity_uv`, which sets the `BBMOD_U_BASE_OPACITY_UV` uniform.
* Added new function `bbmod_shader_set_normal_w_uv`, which sets the `BBMOD_U_NORMAL_W_UV` uniform.
* Added new function `bbmod_shader_set_material_uv`, which sets the `BBMOD_U_MATERIAL_UV` uniform.
* Added new function `bbmod_shader_set_alpha_test`, which sets the `BBMOD_U_ALPHA_TEST` uniform.
* Added new function `bbmod_shader_set_cam_pos`, which sets the `BBMOD_U_CAM_POS` uniform.
* Added new function `bbmod_shader_set_zfar`, which sets the `BBMOD_U_ZFAR` uniform.
* Added new function `bbmod_shader_set_exposure`, which sets the `BBMOD_U_EXPOSURE` uniform.
* Added new function `bbmod_shader_set_soft_distance`, which sets the `BBMOD_U_SOFT_DISTANCE` uniform.
* Added new function `bbmod_shader_set_fog`, which sets uniforms `BBMOD_U_FOG_COLOR`, `BBMOD_U_FOG_INTENSITY`, `BBMOD_U_FOG_START` and `BBMOD_U_FOG_RCP_RANGE`.
* Added new function `bbmod_shader_set_ambient_light`, which sets uniforms `BBMOD_U_LIGHT_AMBIENT_UP`, `BBMOD_U_LIGHT_AMBIENT_DOWN` and `BBMOD_U_LIGHT_AMBIENT_DIR_UP`.
* Added new function `bbmod_shader_set_directional_light`, which sets uniforms `BBMOD_U_LIGHT_DIRECTIONAL_DIR` and `BBMOD_U_LIGHT_DIRECTIONAL_COLOR`.
* Added new function `bbmod_shader_set_ssao`, which sets the `BBMOD_U_SSAO` uniform.
* Added new function `bbmod_shader_set_ibl`, which sets uniforms `BBMOD_U_IBL_ENABLE`, `BBMOD_U_IBL_TEXEL` and `BBMOD_U_IBL`.
* Added new function `bbmod_shader_set_punctual_lights`, which sets uniforms `BBMOD_U_LIGHT_PUNCTUAL_DATA_A` and `BBMOD_U_LIGHT_PUNCTUAL_DATA_B`.
* Added new function `bbmod_shader_set_shadowmap_bias`, which sets the `BBMOD_U_SHADOWMAP_BIAS` uniform.
* Added new function `bbmod_shader_set_hdr`, which sets the `BBMOD_U_HDR` uniform.
* Method `set_texture_offset` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_texture_offset` instead.
* Method `set_texture_scale` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_texture_scale` instead.
* Method `set_bones` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_bones` instead.
* Method `set_batch_data` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_batch_data` instead.
* Method `set_alpha_test` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_alpha_test` instead.
* Method `set_cam_pos` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_cam_pos` instead.
* Method `set_exposure` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_exposure` instead.
* Method `set_set_instance_id` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_instance_id` instead.
* Method `set_set_material_index` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_material_index` instead.
* Method `set_set_ibl` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_ibl` instead.
* Method `set_ambient_light` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_ambient_light` instead.
* Method `set_directional_light` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_directional_light` instead.
* Method `set_punctual_lights` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_punctual_lights` instead.
* Method `set_fog` of `BBMOD_BaseShader` is now **deprecated**! Please use the new function `bbmod_shader_set_fog` instead.
* Method `set_normal_smoothness` of `BBMOD_DefaultShader` is now **deprecated**! Please use the new function `bbmod_shader_set_normal_smoothness` instead.
* Method `set_specular_color` of `BBMOD_DefaultShader` is now **deprecated**! Please use the new function `bbmod_shader_set_specular_color` instead.
* Method `set_normal_roughness` of `BBMOD_DefaultShader` is now **deprecated**! Please use the new function `bbmod_shader_set_normal_roughness` instead.
* Method `set_metallic_ao` of `BBMOD_DefaultShader` is now **deprecated**! Please use the new function `bbmod_shader_set_metallic_ao` instead.
* Method `set_subsurface` of `BBMOD_DefaultShader` is now **deprecated**! Please use the new function `bbmod_shader_set_subsurface` instead.
* Method `set_emissive` of `BBMOD_DefaultShader` is now **deprecated**! Please use the new function `bbmod_shader_set_emissive` instead.
* Method `set_lightmap` of `BBMOD_DefaultLightmapShader` is now **deprecated**! Please use the new function `bbmod_shader_set_lightmap` instead.
* Fixed `BBMOD_PunctualLight` not affecting particles by default.
* Fixed function `bbmod_mrt_is_supported` not working on Mac.
* Fixed method `clone` of `BBMOD_TerrainMaterial`, which returned instances of `BBMOD_BaseMaterial`.
* Fixed materials with `AlphaBlend` enabled not working in the `Id` render pass.
