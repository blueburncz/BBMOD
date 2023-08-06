/// @module Core

////////////////////////////////////////////////////////////////////////////////
//
// BBMOD release version
//

/// @macro {Real} The major version number of this BBMOD release.
#macro BBMOD_RELEASE_MAJOR 3

/// @macro {Real} The minor version number of this BBMOD release.
#macro BBMOD_RELEASE_MINOR 17

/// @macro {Real} The patch version number of this BBMOD release.
#macro BBMOD_RELEASE_PATCH 2

/// @macro {String} The version of this BBMOD release as a string ("major.minor.patch" format).
#macro BBMOD_RELEASE_STRING $"{BBMOD_RELEASE_MAJOR}.{BBMOD_RELEASE_MINOR}.{BBMOD_RELEASE_PATCH}"

////////////////////////////////////////////////////////////////////////////////
//
// File format versioning
//

/// @macro {Real} The supported major version of BBMOD and BBANIM files.
/// @see BBMOD_VERSION_MINOR
#macro BBMOD_VERSION_MAJOR 3

/// @macro {Real} The current minor version of BBMOD and BBANIM files.
/// @see BBMOD_VERSION_MAJOR
#macro BBMOD_VERSION_MINOR 4

////////////////////////////////////////////////////////////////////////////////
//
// Vertex normals generation
//

/// @macro {Real} A value used to tell that no normals should be generated
/// if the model does not have any.
/// @see BBMOD_NORMALS_FLAT
/// @see BBMOD_NORMALS_SMOOTH
#macro BBMOD_NORMALS_NONE 0

/// @macro {Real} A value used to tell that flat normals should be generated
/// if the model does not have any.
/// @see BBMOD_NORMALS_NONE
/// @see BBMOD_NORMALS_SMOOTH
#macro BBMOD_NORMALS_FLAT 1

/// @macro {Real} A value used to tell that smooth normals should be generated
/// if the model does not have any.
/// @see BBMOD_NORMALS_NONE
/// @see BBMOD_NORMALS_FLAT
#macro BBMOD_NORMALS_SMOOTH 2

////////////////////////////////////////////////////////////////////////////////
//
// Vertex shader uniforms
//

/// @macro {String} Name of a vertex shader uniform of type `mat4` that holds
/// a matrix using which normal vectors of vertices are transformed.
/// @see bbmod_matrix_build_normalmatrix
#macro BBMOD_U_NORMAL_MATRIX "bbmod_NormalMatrix"

/// @macro {String} Name of a vertex shader uniform of type `vec2` that holds
/// offset of texture coordinates.
#macro BBMOD_U_TEXTURE_OFFSET "bbmod_TextureOffset"

/// @macro {String} Name of a vertex shader uniform of type `vec2` that holds
/// scale of texture coordinates.
#macro BBMOD_U_TEXTURE_SCALE "bbmod_TextureScale"

/// @macro {String} Name of a vertex shader uniform of type
/// `vec4[2 * BBMOD_MAX_BONES]` that holds bone transformation data.
/// @see BBMOD_MAX_BONES
#macro BBMOD_U_BONES "bbmod_Bones"

/// @macro {String} Name of a vertex shader uniform of type
/// `vec4[BBMOD_MAX_BATCH_VEC4S]` that holds dynamic batching data.
/// @see BBMOD_MAX_BATCH_VEC4S
#macro BBMOD_U_BATCH_DATA "bbmod_BatchData"

/// @macro {String} Name of a vertex shader uniform of type `float` that holds
/// whether shadowmapping is enabled (1.0) or disabled (0.0).
#macro BBMOD_U_SHADOWMAP_ENABLE_VS "bbmod_ShadowmapEnableVS"

/// @macro {String} Name of a vertex shader uniform of type `mat4` that holds
/// a matrix that transforms vertices from world-space to shadowmap-space.
#macro BBMOD_U_SHADOWMAP_MATRIX "bbmod_ShadowmapMatrix"

/// @macro {String} Name of a vertex shader uniform of type `float` that holds
/// how much are vertices offset by their normal before they are transformed into
/// shadowmap-space, using formula `vertex + normal * normalOffset`.
#macro BBMOD_U_SHADOWMAP_NORMAL_OFFSET "bbmod_ShadowmapNormalOffset"

////////////////////////////////////////////////////////////////////////////////
//
// Fragment shader uniforms
//

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// an ID of the instance that draws the model, encoded into a color.
///
/// @example
/// ```gml
/// shader_set_uniform_f(
///     shader_get_uniform(shader_current(), BBMOD_U_INSTANCE_ID),
///     ((id & $000000FF) >> 0) / 255,
///     ((id & $0000FF00) >> 8) / 255,
///     ((id & $00FF0000) >> 16) / 255,
///     ((id & $FF000000) >> 24) / 255);
/// ```
///
/// @see bbmod_set_instance_id
#macro BBMOD_U_INSTANCE_ID "bbmod_InstanceID"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the index of the current material within array {@link BBMOD_Model.Materials}.
#macro BBMOD_U_MATERIAL_INDEX "bbmod_MaterialIndex"

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// a multiplier for the base opacity texture (`gm_BaseTexture`).
#macro BBMOD_U_BASE_OPACITY_MULTIPLIER "bbmod_BaseOpacityMultiplier"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// whether the material uses roughness workflow (1.0) or not (0.0).
#macro BBMOD_U_IS_ROUGHNESS "bbmod_IsRoughness"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// whether the material uses metallic workflow (1.0) or not (0.0).
#macro BBMOD_U_IS_METALLIC "bbmod_IsMetallic"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds normal smoothness/roughness texture.
#macro BBMOD_U_NORMAL_W "bbmod_NormalW"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with either metalness in the R channel and ambient occlusion
/// in the G channel (for materials using metallic workflow), or specular color
/// in RGB (for materials using specular color workflow).
#macro BBMOD_U_MATERIAL "bbmod_Material"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with subsurface color in RGB and subsurface effect intensity
/// (or model thickness) in the A channel.
#macro BBMOD_U_SUBSURFACE "bbmod_Subsurface"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with RGBM encoded emissive color.
#macro BBMOD_U_EMISSIVE "bbmod_Emissive"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with a baked lightmap applied to the model.
/// @see bbmod_lightmap_set
/// @see bbmod_lightmap_get
#macro BBMOD_U_LIGHTMAP "bbmod_Lightmap"

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// top left and bottom right coordinates of the base opacity texture on its
/// texture page.
#macro BBMOD_U_BASE_OPACITY_UV "bbmod_BaseOpacityUV"

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// top left and bottom right coordinates of the normal texture on its texture
/// page.
#macro BBMOD_U_NORMAL_W_UV "bbmod_NormalWUV"

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// top left and bottom right coordinates of the material texture on its texture
/// page.
#macro BBMOD_U_MATERIAL_UV "bbmod_MaterialUV"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the alpha test threshold value. Fragments with alpha less than this value are
/// discarded.
#macro BBMOD_U_ALPHA_TEST "bbmod_AlphaTest"

/// @macro {String} Name of a fragment shader uniform of type `vec3` that holds
/// the world-space camera position.
/// @see bbmod_camera_set_position
/// @see bbmod_camera_get_position
#macro BBMOD_U_CAM_POS "bbmod_CamPos"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the distance to the far clipping plane.
/// @see bbmod_camera_set_zfar
/// @see bbmod_camera_get_zfar
#macro BBMOD_U_ZFAR "bbmod_ZFar"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the camera exposure value.
/// @see bbmod_camera_set_exposure
/// @see bbmod_camera_get_exposure
#macro BBMOD_U_EXPOSURE "bbmod_Exposure"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds the G-buffer texture. This can also be just the depth texture in a
/// forward rendering pipeline.
#macro BBMOD_U_GBUFFER "bbmod_GBuffer"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// a distance over which particles smoothly disappear when intersecting with
/// geometry in the depth buffer.
#macro BBMOD_U_SOFT_DISTANCE "bbmod_SoftDistance"

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// the fog color.
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_color
#macro BBMOD_U_FOG_COLOR "bbmod_FogColor"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the maximum fog intensity.
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_intensity
#macro BBMOD_U_FOG_INTENSITY "bbmod_FogIntensity"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the distance from the camera at which the fog starts.
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_start
#macro BBMOD_U_FOG_START "bbmod_FogStart"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// `1.0 / (fogEnd - fogStart)`, where `fogEnd` is the distance from the camera
/// where fog reaches its maximum intensity and `fogStart` is the distance from
/// camera where the fog begins.
/// @see bbmod_fog_set_end
/// @see bbmod_fog_get_end
#macro BBMOD_U_FOG_RCP_RANGE "bbmod_FogRcpRange"

/// @macro {String} Name of a fragment shader uniform of type `vec3` that holds
/// the ambient light's up vector.
/// @see bbmod_light_ambient_set_dir
/// @see bbmod_light_ambient_get_dir
#macro BBMOD_U_LIGHT_AMBIENT_DIR_UP "bbmod_LightAmbientDirUp"

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// the ambient light color on the upper hemisphere.
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_get_up
#macro BBMOD_U_LIGHT_AMBIENT_UP "bbmod_LightAmbientUp"

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// the ambient light color on the lower hemisphere.
/// @see bbmod_light_ambient_set_down
/// @see bbmod_light_ambient_get_down
#macro BBMOD_U_LIGHT_AMBIENT_DOWN "bbmod_LightAmbientDown"

/// @macro {String} Name of a fragment shader uniform of type `vec3` that holds
/// the directional light's direction.
/// @see bbmod_light_directional_set
/// @see bbmod_light_directional_get
#macro BBMOD_U_LIGHT_DIRECTIONAL_DIR "bbmod_LightDirectionalDir"

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// the directional light's color in RGB and intensity in the A channel.
/// @see bbmod_light_directional_set
/// @see bbmod_light_directional_get
#macro BBMOD_U_LIGHT_DIRECTIONAL_COLOR "bbmod_LightDirectionalColor"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds the screen-space ambient occlusion texture.
#macro BBMOD_U_SSAO "bbmod_SSAO"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// whether image based lighting is enabled (1.0) or disabled (0.0).
/// @see bbmod_ibl_set
/// @see bbmod_ibl_get
#macro BBMOD_U_IBL_ENABLE "bbmod_IBLEnable"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds the image based lighting texture.
/// @see bbmod_ibl_set
/// @see bbmod_ibl_get
#macro BBMOD_U_IBL "bbmod_IBL"

/// @macro {String} Name of a fragment shader uniform of type `vec2` that holds
/// the texel size of image based lighting texture.
/// @see bbmod_ibl_set
/// @see bbmod_ibl_get
#macro BBMOD_U_IBL_TEXEL "bbmod_IBLTexel"

/// @macro {String} Name of a fragment shader uniform of type
/// `vec4[2 * BBMOD_MAX_PUNCTUAL_LIGHTS]` that holds vectors `(x, y, z, range)`
/// and `(r, g, b, intensity)` for each punctual light.
/// @see BBMOD_MAX_PUNCTUAL_LIGHTS
/// @see bbmod_light_punctual_add
#macro BBMOD_U_LIGHT_PUNCTUAL_DATA_A "bbmod_LightPunctualDataA"

/// @macro {String} Name of a fragment shader uniform of type
/// `vec3[2 * BBMOD_MAX_PUNCTUAL_LIGHTS]` that holds vectors
/// `(isSpotLight, dcosInner, dcosOuter)` and `(dirX, dirY, dirZ)` for each
/// punctual light.
/// @see BBMOD_MAX_PUNCTUAL_LIGHTS
/// @see bbmod_light_punctual_add
#macro BBMOD_U_LIGHT_PUNCTUAL_DATA_B "bbmod_LightPunctualDataB"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds the splatmap texture.
#macro BBMOD_U_SPLATMAP "bbmod_Splatmap"

/// @macro {String} Name of a fragment shader uniform of type `int` that holds
/// the index of a channel to read from the splatmap.
#macro BBMOD_U_SPLATMAP_INDEX "bbmod_SplatmapIndex"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// whether shadowmapping is enabled (1.0) or disabled (0.0).
#macro BBMOD_U_SHADOWMAP_ENABLE_PS "bbmod_ShadowmapEnablePS"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds the shadowmap texture.
#macro BBMOD_U_SHADOWMAP "bbmod_Shadowmap"

/// @macro {String} Name of a fragment shader uniform of type `vec2` that holds
/// the texel size of a shadowmap texture.
#macro BBMOD_U_SHADOWMAP_TEXEL "bbmod_ShadowmapTexel"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the area that the shadowmap captures.
#macro BBMOD_U_SHADOWMAP_AREA "bbmod_ShadowmapArea"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the distance over which models smoothly transition into shadow. Useful for
/// example for volumetric look of particles.
#macro BBMOD_U_SHADOWMAP_BIAS "bbmod_ShadowmapBias"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the index of a punctual light that casts shadows or -1.0, if it's the
/// directional light.
#macro BBMOD_U_SHADOW_CASTER_INDEX "bbmod_ShadowCasterIndex"
