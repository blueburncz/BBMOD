# Changelog dev
> This file is used to accumulate changes before a changelog for a release is
> created.

* Added new enum `BBMOD_EShaderUniformType`, which is an enumeration of shader uniform types.
* Added new struct `BBMOD_MaterialPropertyBlock`, which is a collection of material properties. Useful in case you want to use the same material when rendering multiple models and only change some of its properties for each model.
* Added new function `bbmod_material_props_set`, using which you can set the current material property block.
* Added new function `bbmod_material_props_get`, using which you can retrieve the current material property block.
* Added new function `bbmod_material_props_reset`, using which you can unset the current material property block.
* Added new member `ApplyMaterialProps` to enum `BBMOD_ERenderCommand`, which is a render command to apply a material property block.
* Added new member `SetMaterialProps` to enum `BBMOD_ERenderCommand`, which is a render command to set current material property block.
* Added new member `ResetMaterialProps` to enum `BBMOD_ERenderCommand`, which is a render command to reset current material property block.
* Added new method `apply_material_props` to struct `BBMOD_RenderQueue`, which adds a `BBMOD_ERenderCommand.ApplyMaterialProps` command into the queue.
* Added new method `set_material_props` to struct `BBMOD_RenderQueue`, which adds a `BBMOD_ERenderCommand.SetMaterialProps` command into the queue.
* Added new method `reset_material_props` to struct `BBMOD_RenderQueue`, which adds a `BBMOD_ERenderCommand.ResetMaterialProps` command into the queue.
* Added new macro `BBMOD_U_NORMAL_MATRIX`, which is the name of a vertex shader uniform of type `mat4` that holds a matrix using which normal vectors of vertices are transformed.
* Added new macro `BBMOD_U_TEXTURE_OFFSET`, which is the name of a vertex shader uniform of type `vec2` that holds offset of texture coordinates.
* Added new macro `BBMOD_U_TEXTURE_SCALE`, which is the name of a vertex shader uniform of type `vec2` that holds scale of texture coordinates.
* Added new macro `BBMOD_U_BONES`, which is the name of a vertex shader uniform of type `vec4[2 * BBMOD_MAX_BONES]` that holds bone transformation data.
* Added new macro `BBMOD_U_BATCH_DATA`, which is the name of a vertex shader uniform of type `vec4[BBMOD_MAX_BATCH_VEC4S]` that holds dynamic batching data.
* Added new macro `BBMOD_U_SHADOWMAP_ENABLE_VS`, which is the name of a vertex shader uniform of type `float` that holds whether shadowmapping is enabled (1.0) or disabled (0.0).
* Added new macro `BBMOD_U_SHADOWMAP_MATRIX`, which is the name of a vertex shader uniform of type `mat4` that holds a matrix that transforms vertices from world-space to shadowmap-space.
* Added new macro `BBMOD_U_SHADOWMAP_NORMAL_OFFSET`, which is the name of a vertex shader uniform of type `float` that holds how much are vertices offset by their normal before they are transformed into shadowmap-space, using formula `vertex + normal * normalOffset`.
* Added new macro `BBMOD_U_INSTANCE_ID`, which is the name of a fragment shader uniform of type `vec4` that holds an ID of the instance that draws the model, encoded into a color.
* Added new macro `BBMOD_U_MATERIAL_INDEX`, which is the name of a fragment shader uniform of type `float` that holds the index of the current material within array `BBMOD_Model.Materials`.
* Added new macro `BBMOD_U_BASE_OPACITY_MULTIPLIER`, which is the name of a fragment shader uniform of type `vec4` that holds a multiplier for the base opacity texture (`gm_BaseTexture`).
* Added new macro `BBMOD_U_IS_ROUGHNESS`, which is the name of a fragment shader uniform of type `float` that holds whether the material uses roughness workflow (1.0) or not (0.0).
* Added new macro `BBMOD_U_IS_METALLIC`, which is the name of a fragment shader uniform of type `float` that holds whether the material uses metallic workflow (1.0) or not (0.0).
* Added new macro `BBMOD_U_NORMAL_W`, which is the name of a fragment shader uniform of type `sampler2D` that holds normal smoothness/roughness texture.
* Added new macro `BBMOD_U_MATERIAL`, which is the name of a fragment shader uniform of type `sampler2D` that holds a texture with either metalness in the R channel and ambient occlusion in the G channel (for materials using metallic workflow), or specular color in RGB (for materials using specular color workflow).
* Added new macro `BBMOD_U_SUBSURFACE`, which is the name of a fragment shader uniform of type `sampler2D` that holds a texture with subsurface color in RGB and subsurface effect intensity (or model thickness) in the A channel.
* Added new macro `BBMOD_U_EMISSIVE`, which is the name of a fragment shader uniform of type `sampler2D` that holds a texture with RGBM encoded emissive color.
* Added new macro `BBMOD_U_LIGHTMAP`, which is the name of a fragment shader uniform of type `sampler2D` that holds a texture with a baked lightmap applied to the model.
* Added new macro `BBMOD_U_BASE_OPACITY_UV`, which is the name of a fragment shader uniform of type `vec4` that holds top left and bottom right coordinates of the base opacity texture on its texture page.
* Added new macro `BBMOD_U_NORMAL_W_UV`, which is the name of a fragment shader uniform of type `vec4` that holds top left and bottom right coordinates of the normal texture on its texture page.
* Added new macro `BBMOD_U_MATERIAL_UV`, which is the name of a fragment shader uniform of type `vec4` that holds top left and bottom right coordinates of the material texture on its texture page.
* Added new macro `BBMOD_U_ALPHA_TEST`, which is the name of a fragment shader uniform of type `float` that holds the alpha test threshold value. Fragments with alpha less than this value are discarded.
* Added new macro `BBMOD_U_CAM_POS`, which is the name of a fragment shader uniform of type `vec3` that holds the world-space camera position.
* Added new macro `BBMOD_U_ZFAR`, which is the name of a fragment shader uniform of type `float` that holds the distance to the far clipping plane.
* Added new macro `BBMOD_U_EXPOSURE`, which is the name of a fragment shader uniform of type `float` that holds the camera exposure value.
* Added new macro `BBMOD_U_GBUFFER`, which is the name of a fragment shader uniform of type `sampler2D` that holds the G-buffer texture. This can also be just the depth texture in a forward rendering pipeline.
* Added new macro `BBMOD_U_SOFT_DISTANCE`, which is the name of a fragment shader uniform of type `float` that holds a distance over which particles smoothly disappear when intersecting with geometry in the depth buffer.
* Added new macro `BBMOD_U_FOG_COLOR`, which is the name of a fragment shader uniform of type `vec4` that holds the fog color.
* Added new macro `BBMOD_U_FOG_INTENSITY`, which is the name of a fragment shader uniform of type `float` that holds the maximum fog intensity.
* Added new macro `BBMOD_U_FOG_START`, which is the name of a fragment shader uniform of type `float` that holds the distance from the camera at which the fog starts.
* Added new macro `BBMOD_U_FOG_RCP_RANGE`, which is the name of a fragment shader uniform of type `float` that holds `1.0 / (fogEnd - fogStart)`, where `fogEnd` is the distance from the camera where fog reaches its maximum intensity and `fogStart` is the distance from camera where the fog begins.
* Added new macro `BBMOD_U_LIGHT_AMBIENT_DIR_UP`, which is the name of a fragment shader uniform of type `vec3` that holds the ambient light's up vector.
* Added new macro `BBMOD_U_LIGHT_AMBIENT_UP`, which is the name of a fragment shader uniform of type `vec4` that holds the ambient light color on the upper hemisphere.
* Added new macro `BBMOD_U_LIGHT_AMBIENT_DOWN`, which is the name of a fragment shader uniform of type `vec4` that holds the ambient light color on the lower hemisphere.
* Added new macro `BBMOD_U_LIGHT_DIRECTIONAL_DIR`, which is the name of a fragment shader uniform of type `vec3` that holds the directional light's direction.
* Added new macro `BBMOD_U_LIGHT_DIRECTIONAL_COLOR`, which is the name of a fragment shader uniform of type `vec4` that holds the directional light's color in RGB and intensity in the A channel.
* Added new macro `BBMOD_U_SSAO`, which is the name of a fragment shader uniform of type `sampler2D` that holds the screen-space ambient occlusion texture.
* Added new macro `BBMOD_U_IBL_ENABLE`, which is the name of a fragment shader uniform of type `float` that holds whether image based lighting is enabled (1.0) or disabled (0.0).
* Added new macro `BBMOD_U_IBL`, which is the name of a fragment shader uniform of type `sampler2D` that holds the image based lighting texture.
* Added new macro `BBMOD_U_IBL_TEXEL`, which is the name of a fragment shader uniform of type `vec2` that holds the texel size of image based lighting texture.
* Added new macro `BBMOD_U_LIGHT_PUNCTUAL_DATA_A`, which is the name of a fragment shader uniform of type `vec4[2 * BBMOD_MAX_PUNCTUAL_LIGHTS]` that holds vectors `(x, y, z, range)` and `(r, g, b, intensity)` for each punctual light.
* Added new macro `BBMOD_U_LIGHT_PUNCTUAL_DATA_B`, which is the name of a fragment shader uniform of type `vec3[2 * BBMOD_MAX_PUNCTUAL_LIGHTS]` that holds vectors `(isSpotLight, dcosInner, dcosOuter)` and `(dirX, dirY, dirZ)` for each punctual light.
* Added new macro `BBMOD_U_SPLATMAP`, which is the name of a fragment shader uniform of type `sampler2D` that holds the splatmap texture.
* Added new macro `BBMOD_U_SPLATMAP_INDEX`, which is the name of a fragment shader uniform of type `int` that holds the index of a channel to read from the splatmap.
* Added new macro `BBMOD_U_SHADOWMAP_ENABLE_PS`, which is the name of a fragment shader uniform of type `float` that holds whether shadowmapping is enabled (1.0) or disabled (0.0).
* Added new macro `BBMOD_U_SHADOWMAP`, which is the name of a fragment shader uniform of type `sampler2D` that holds the shadowmap texture.
* Added new macro `BBMOD_U_SHADOWMAP_TEXEL`, which is the name of a fragment shader uniform of type `vec2` that holds the texel size of a shadowmap texture.
* Added new macro `BBMOD_U_SHADOWMAP_AREA`, which is the name of a fragment shader uniform of type `float` that holds the area that the shadowmap captures.
* Added new macro `BBMOD_U_SHADOWMAP_BIAS`, which is the name of a fragment shader uniform of type `float` that holds the distance over which models smoothly transition into shadow. Useful for example for volumetric look of particles.
* Added new macro `BBMOD_U_SHADOW_CASTER_INDEX`, which is the name of a fragment shader uniform of type `float` that holds the index of a punctual light that casts shadows or -1.0, if it's the directional light.
* Added new macro `BBMOD_MAX_PUNCTUAL_LIGHTS`, which is the maximum number of punctual lights in shaders. Equals to 8.
* Property `BBMOD_BaseShader.MaxPunctualLights` is now read-only and deprecated. Please use the new macro `BBMOD_MAX_PUNCTUAL_LIGHTS` instead.
* Added new method `Negate` to structs `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4`, which negates the vector and returns the result as a new vector.
* Fixed methods `world_to_screen` and `screen_point_to_vec3` of `BBMOD_BaseCamera`, which returned coordinates mirrored on the Y axis on some platforms.
* Fixed `BBMOD_Cubemap` contents being flipped vertically on Windows.
* Fixed crash in `bbmod_instance_to_buffer` when saving `BBMOD_EPropertyType.RealArray` properties.
* Fixed gizmo, which did not work after update 3.16.8.
