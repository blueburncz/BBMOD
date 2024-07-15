////////////////////////////////////////////////////////////////////////////////
//
// Vertex shader uniforms
//

/// @macro {String} Name of a vertex shader uniform of type `mat4` that holds
/// a matrix using which normal vectors of vertices are transformed.
/// @see bbmod_matrix_build_normalmatrix
#macro BBMOD_U_NORMAL_MATRIX "bbmod_NormalMatrix"

/// @func bbmod_shader_set_normal_matrix(_shader, _matrix)
///
/// @desc Sets the {@link BBMOD_U_NORMAL_MATRIX} uniform to the given matrix.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Array<Real>} _matrix The new normal matrix.
///
/// @see bbmod_matrix_build_normalmatrix
function bbmod_shader_set_normal_matrix(_shader, _matrix)
{
	gml_pragma("forceinline");
	shader_set_uniform_matrix_array(
		shader_get_uniform(_shader, BBMOD_U_NORMAL_MATRIX),
		_matrix);
}

/// @macro {String} Name of a vertex shader uniform of type `vec2` that holds
/// offset of texture coordinates.
#macro BBMOD_U_TEXTURE_OFFSET "bbmod_TextureOffset"

/// @func bbmod_shader_set_texture_offset(_shader, _offset)
///
/// @desc Sets the {@link BBMOD_U_TEXTURE_OFFSET} uniform to the given offset.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Struct.BBMOD_Vec2} _offset The texture offset.
function bbmod_shader_set_texture_offset(_shader, _offset)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_TEXTURE_OFFSET),
		_offset.X, _offset.Y);
}

/// @macro {String} Name of a vertex shader uniform of type `vec2` that holds
/// scale of texture coordinates.
#macro BBMOD_U_TEXTURE_SCALE "bbmod_TextureScale"

/// @func bbmod_shader_set_texture_scale(_shader, _scale)
///
/// @desc Sets the {@link BBMOD_U_TEXTURE_SCALE} uniform to the given scale.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Struct.BBMOD_Vec2} _scale The texture scale.
function bbmod_shader_set_texture_scale(_shader, _scale)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_TEXTURE_SCALE),
		_scale.X, _scale.Y);
}

/// @macro {String} Name of a vertex shader uniform of type
/// `vec4[2 * BBMOD_MAX_BONES]` that holds bone transformation data.
/// @see BBMOD_MAX_BONES
#macro BBMOD_U_BONES "bbmod_Bones"

/// @func bbmod_shader_set_bones(_shader, _bones)
///
/// @desc Sets the {@link BBMOD_U_BONES} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Array<Real>} _bones The array of bone transforms.
///
/// @see BBMOD_AnimationPlayer.get_transform
function bbmod_shader_set_bones(_shader, _bones)
{
	gml_pragma("forceinline");
	shader_set_uniform_f_array(
		shader_get_uniform(_shader, BBMOD_U_BONES),
		_bones);
}

/// @macro {String} Name of a vertex shader uniform of type
/// `vec4[BBMOD_MAX_BATCH_VEC4S]` that holds dynamic batching data.
/// @see BBMOD_MAX_BATCH_VEC4S
#macro BBMOD_U_BATCH_DATA "bbmod_BatchData"

/// @func bbmod_shader_set_batch_data(_shader, _data)
///
/// @desc Sets the {@link BBMOD_U_BATCH_DATA} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Array<Real>} _data The dynamic batch data.
function bbmod_shader_set_batch_data(_shader, _data)
{
	gml_pragma("forceinline");
	shader_set_uniform_f_array(
		shader_get_uniform(_shader, BBMOD_U_BATCH_DATA),
		_data);
}

/// @macro {String} Name of a vertex shader uniform of type `float` that holds
/// whether shadowmapping is enabled (1.0) or disabled (0.0).
#macro BBMOD_U_SHADOWMAP_ENABLE_VS "bbmod_ShadowmapEnableVS"

/// @macro {String} Name of a vertex shader uniform of type `mat4` that holds
/// a matrix that transforms vertices from world-space to shadowmap-space.
#macro BBMOD_U_SHADOWMAP_MATRIX "bbmod_ShadowmapMatrix"

/// @macro {String} Name of a vertex shader uniform of type `float` that holds
/// how much are vertices offset by their normal before they are transformed into
/// shadowmap-space, using formula `vertex + normal * normalOffset`.
/// @obsolete Please use {@link BBMOD_U_SHADOWMAP_NORMAL_OFFSET_VS} instead.
#macro BBMOD_U_SHADOWMAP_NORMAL_OFFSET "bbmod_ShadowmapNormalOffset"

/// @macro {String} Name of a vertex shader uniform of type `float` that holds
/// how much are vertices offset by their normal before they are transformed into
/// shadowmap-space, using formula `vertex + normal * normalOffset`.
#macro BBMOD_U_SHADOWMAP_NORMAL_OFFSET_VS "bbmod_ShadowmapNormalOffsetVS"

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
///     shader_get_uniform(_shader, BBMOD_U_INSTANCE_ID),
///     ((id & $000000FF) >> 0) / 255,
///     ((id & $0000FF00) >> 8) / 255,
///     ((id & $00FF0000) >> 16) / 255,
///     ((id & $FF000000) >> 24) / 255);
/// ```
///
/// @see bbmod_set_instance_id
#macro BBMOD_U_INSTANCE_ID "bbmod_InstanceID"

/// @func bbmod_shader_set_instance_id(_shader[, _id])
///
/// @desc Sets the {@link BBMOD_U_INSTANCE_ID} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Id.Instance} [_id] The instance ID. If `undefined`,
/// then the value set by {@link bbmod_set_instance_id} is used.
function bbmod_shader_set_instance_id(_shader, _id=undefined)
{
	gml_pragma("forceinline");
	_id ??= global.__bbmodInstanceID;
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_INSTANCE_ID),
		((_id & $000000FF) >> 0) / 255,
		((_id & $0000FF00) >> 8) / 255,
		((_id & $00FF0000) >> 16) / 255,
		((_id & $FF000000) >> 24) / 255);
}

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the index of the current material within array {@link BBMOD_Model.Materials}.
#macro BBMOD_U_MATERIAL_INDEX "bbmod_MaterialIndex"

/// @func bbmod_shader_set_material_index(_shader, _index)
///
/// @desc Sets the {@link BBMOD_U_MATERIAL_INDEX} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Real} [_index] The index of the current material.
function bbmod_shader_set_material_index(_shader, _index)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_MATERIAL_INDEX),
		_index);
}

/// @var {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with base color in RGB channels and opacity in the A channel.
#macro BBMOD_U_BASE_OPACITY "gm_BaseTexture"

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// a multiplier for the base opacity texture (`gm_BaseTexture`).
#macro BBMOD_U_BASE_OPACITY_MULTIPLIER "bbmod_BaseOpacityMultiplier"

/// @func bbmod_shader_set_base_opacity_multiplier(_shader, _color)
///
/// @desc Sets the {@link BBMOD_U_BASE_OPACITY_MULTIPLIER} uniform to the given
/// color.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Struct.BBMOD_Color} _color The new base opacity multiplier.
function bbmod_shader_set_base_opacity_multiplier(_shader, _color)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_BASE_OPACITY_MULTIPLIER),
		_color.Red / 255.0,
		_color.Green / 255.0,
		_color.Blue / 255.0,
		_color.Alpha);
}

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// whether the material uses roughness workflow (1.0) or not (0.0).
#macro BBMOD_U_IS_ROUGHNESS "bbmod_IsRoughness"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds normal smoothness/roughness texture.
#macro BBMOD_U_NORMAL_W "bbmod_NormalW"

/// @func bbmod_shader_set_normal_smoothness(_shader, _texture)
///
/// @desc Sets uniforms {@link BBMOD_U_NORMAL_W} and {@link BBMOD_U_IS_ROUGHNESS}.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Pointer.Texture} _texture The new texture with normal vector i
/// the RGB channels and smoothness in the A channel.
function bbmod_shader_set_normal_smoothness(_shader, _texture)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_IS_ROUGHNESS),
		0.0);
	texture_set_stage(
		shader_get_sampler_index(_shader, BBMOD_U_NORMAL_W),
		_texture);
}

/// @func bbmod_shader_set_normal_roughness(_shader, _texture)
///
/// @desc Sets uniforms {@link BBMOD_U_NORMAL_W} and {@link BBMOD_U_IS_ROUGHNESS}.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Pointer.Texture} _texture The new texture with normal vector in
/// the RGB channels and roughness in the A channel.
function bbmod_shader_set_normal_roughness(_shader, _texture)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_IS_ROUGHNESS),
		1.0);
	texture_set_stage(
		shader_get_sampler_index(_shader, BBMOD_U_NORMAL_W),
		_texture);
}

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// whether the material uses metallic workflow (1.0) or not (0.0).
#macro BBMOD_U_IS_METALLIC "bbmod_IsMetallic"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with either metalness in the R channel and ambient occlusion
/// in the G channel (for materials using metallic workflow), or specular color
/// in RGB (for materials using specular color workflow).
#macro BBMOD_U_MATERIAL "bbmod_Material"

/// @func bbmod_shader_set_specular_color(_shader, _texture)
///
/// @desc Sets uniforms {@link BBMOD_U_MATERIAL} and {@link BBMOD_U_IS_METALLIC}.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Pointer.Texture} _texture The new texture with specular color in
/// the RGB channels.
function bbmod_shader_set_specular_color(_shader, _texture)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_IS_METALLIC),
		0.0);
	texture_set_stage(
		shader_get_sampler_index(_shader, BBMOD_U_MATERIAL),
		_texture);
}

/// @func bbmod_shader_set_metallic_ao(_shader, _texture)
///
/// @desc Sets uniforms {@link BBMOD_U_MATERIAL} and {@link BBMOD_U_IS_METALLIC}.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Pointer.Texture} _texture The new texture with metalness in the
/// R channel and ambient occlusion in the G channel.
function bbmod_shader_set_metallic_ao(_shader, _texture)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_IS_METALLIC),
		1.0);
	texture_set_stage(
		shader_get_sampler_index(_shader, BBMOD_U_MATERIAL),
		_texture);
}

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with subsurface color in RGB and subsurface effect intensity
/// (or model thickness) in the A channel.
#macro BBMOD_U_SUBSURFACE "bbmod_Subsurface"

/// @func bbmod_shader_set_subsurface(_shader, _texture)
///
/// @desc Sets the {@link BBMOD_U_SUBSURFACE} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Pointer.Texture} _texture The new texture with subsurface color
/// in the RGB channels and its intensity in the A channel.
function bbmod_shader_set_subsurface(_shader, _texture)
{
	gml_pragma("forceinline");
	texture_set_stage(
		shader_get_sampler_index(_shader, BBMOD_U_SUBSURFACE),
		_texture);
}

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with RGBM encoded emissive color.
#macro BBMOD_U_EMISSIVE "bbmod_Emissive"

/// @func bbmod_shader_set_emissive(_shader, _texture)
///
/// @desc Sets the {@link BBMOD_U_EMISSIVE} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Pointer.Texture} _texture The new texture with RGBM encoded
/// emissive color.
function bbmod_shader_set_emissive(_shader, _texture)
{
	gml_pragma("forceinline");
	texture_set_stage(
		shader_get_sampler_index(_shader, BBMOD_U_EMISSIVE),
		_texture);
}

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with a baked lightmap applied to the model.
/// @see bbmod_lightmap_set
/// @see bbmod_lightmap_get
#macro BBMOD_U_LIGHTMAP "bbmod_Lightmap"

/// @func bbmod_shader_set_lightmap(_shader[, _texture])
///
/// @desc Sets the {@link BBMOD_U_LIGHTMAP} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Pointer.Texture} [_texture] The new RGBM encoded lightmap
/// texture. If not specified, defaults to the one configured using
/// {@link bbmod_lightmap_set}.
function bbmod_shader_set_lightmap(_shader, _texture=bbmod_lightmap_get())
{
	gml_pragma("forceinline");
	var _uLightmap = shader_get_sampler_index(_shader, BBMOD_U_LIGHTMAP);
	texture_set_stage(_uLightmap, _texture);
	gpu_set_tex_mip_enable_ext(_uLightmap, mip_off);
	gpu_set_tex_filter_ext(_uLightmap, true);
}

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// top left and bottom right coordinates of the base opacity texture on its
/// texture page.
#macro BBMOD_U_BASE_OPACITY_UV "bbmod_BaseOpacityUV"

/// @func bbmod_shader_set_base_opacity_uv(_shader, _uv)
///
/// @desc Sets the {@link BBMOD_U_BASE_OPACITY_UV} uniform to given values.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Array<Real>} _uv The new base opacity texture UVs as `[left, top, right bottom]`
/// (same as function `texture_get_uvs` returns).
function bbmod_shader_set_base_opacity_uv(_shader, _uv)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_BASE_OPACITY_UV),
		_uv[0],
		_uv[1],
		_uv[2],
		_uv[3]);
}

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// top left and bottom right coordinates of the normal texture on its texture
/// page.
#macro BBMOD_U_NORMAL_W_UV "bbmod_NormalWUV"

/// @func bbmod_shader_set_normal_w_uv(_shader, _uv)
///
/// @desc Sets the {@link BBMOD_U_NORMAL_W_UV} uniform to given values.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Array<Real>} _uv The new base opacity texture UVs as `[left, top, right bottom]`
/// (same as function `texture_get_uvs` returns).
function bbmod_shader_set_normal_w_uv(_shader, _uv)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_NORMAL_W_UV),
		_uv[0],
		_uv[1],
		_uv[2],
		_uv[3]);
}

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// top left and bottom right coordinates of the material texture on its texture
/// page.
#macro BBMOD_U_MATERIAL_UV "bbmod_MaterialUV"

/// @func bbmod_shader_set_material_uv(_shader, _uv)
///
/// @desc Sets the {@link BBMOD_U_MATERIAL_UV} uniform to given values.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Array<Real>} _uv The new base opacity texture UVs as `[left, top, right bottom]`
/// (same as function `texture_get_uvs` returns).
function bbmod_shader_set_material_uv(_shader, _uv)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_MATERIAL_UV),
		_uv[0],
		_uv[1],
		_uv[2],
		_uv[3]);
}

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// top left and bottom right coordinates of the subsurface texture on its
/// texture page.
#macro BBMOD_U_SUBSURFACE_UV "bbmod_SubsurfaceUV"

/// @func bbmod_shader_set_subsurface_uv(_shader, _uv)
///
/// @desc Sets the {@link BBMOD_U_SUBSURFACE_UV} uniform to given values.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Array<Real>} _uv The new base opacity texture UVs as `[left, top, right bottom]`
/// (same as function `texture_get_uvs` returns).
function bbmod_shader_set_subsurface_uv(_shader, _uv)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_SUBSURFACE_UV),
		_uv[0],
		_uv[1],
		_uv[2],
		_uv[3]);
}

/// @macro {String} Name of a fragment shader uniform of type `vec4` that holds
/// top left and bottom right coordinates of the emissive texture on its texture
/// page.
#macro BBMOD_U_EMISSIVE_UV "bbmod_EmissiveUV"

/// @func bbmod_shader_set_emissive_uv(_shader, _uv)
///
/// @desc Sets the {@link BBMOD_U_EMISSIVE_UV} uniform to given values.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Array<Real>} _uv The new base opacity texture UVs as `[left, top, right bottom]`
/// (same as function `texture_get_uvs` returns).
function bbmod_shader_set_emissive_uv(_shader, _uv)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_EMISSIVE_UV),
		_uv[0],
		_uv[1],
		_uv[2],
		_uv[3]);
}

/// @macro {String} Name of a fragment shader uniform of type `float` that
/// equals 1 when the material is two-sided or 0 when it is not. If a material
/// is two-sided, normal vectors of backfaces are flipped before shading.
#macro BBMOD_U_TWO_SIDED "bbmod_TwoSided"

/// @func bbmod_shader_set_two_sided(_shader, _twoSided)
///
/// @desc Sets the {@link BBMOD_U_TWO_SIDED} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Bool} _twoSided Whether the material is two-sided.
function bbmod_shader_set_two_sided(_shader, _twoSided)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_TWO_SIDED),
		_twoSided ? 1.0 : 0.0);
}

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the alpha test threshold value. Fragments with alpha less than this value are
/// discarded.
#macro BBMOD_U_ALPHA_TEST "bbmod_AlphaTest"

/// @func bbmod_shader_set_alpha_test(_shader, _value)
///
/// @desc Sets the {@link BBMOD_U_ALPHA_TEST} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Real} _value The alpha test value.
function bbmod_shader_set_alpha_test(_shader, _value)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_ALPHA_TEST),
		_value);
}

/// @macro {String} Name of a fragment shader uniform of type `vec3` that holds
/// the world-space camera position.
/// @see bbmod_camera_set_position
/// @see bbmod_camera_get_position
#macro BBMOD_U_CAM_POS "bbmod_CamPos"

/// @func bbmod_shader_set_cam_pos(_shader[, _pos])
///
/// @desc Sets a fragment shader uniform {@link BBMOD_U_CAM_POS} to the given position.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Struct.BBMOD_Vec3} [_pos] The camera position. If `undefined`,
/// then the value set by {@link bbmod_camera_set_position} is used.
function bbmod_shader_set_cam_pos(_shader, _pos=undefined)
{
	gml_pragma("forceinline");
	_pos ??= global.__bbmodCameraPosition;
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_CAM_POS),
		_pos.X, _pos.Y, _pos.Z);
}

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the distance to the far clipping plane.
/// @see bbmod_camera_set_zfar
/// @see bbmod_camera_get_zfar
#macro BBMOD_U_ZFAR "bbmod_ZFar"

/// @func bbmod_shader_set_zfar(_shader[, _zfar])
///
/// @desc Sets the {@link BBMOD_U_ZFAR} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Real} [_zfar] The new Z far value. Defaults to the value set using
/// {@link bbmod_camera_set_zfar} if `undefined`.
function bbmod_shader_set_zfar(_shader, _zfar=undefined)
{
	gml_pragma("forceinline");
	_zfar ??= global.__bbmodZFar;
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_ZFAR),
		_zfar);
}

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the camera exposure value.
/// @see bbmod_camera_set_exposure
/// @see bbmod_camera_get_exposure
#macro BBMOD_U_EXPOSURE "bbmod_Exposure"

/// @func bbmod_shader_set_exposure(_shader[, _value])
/// 
/// @desc Sets the {@link BBMOD_U_EXPOSURE} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Real} [_value] The camera exposure. If `undefined`,
/// then the value set by {@link bbmod_camera_set_exposure} is used.
function bbmod_shader_set_exposure(_shader, _value=undefined)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_EXPOSURE),
		_value ?? global.__bbmodCameraExposure);
}

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds the G-buffer texture. This can also be just the depth texture in a
/// forward rendering pipeline.
#macro BBMOD_U_GBUFFER "bbmod_GBuffer"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// a distance over which particles smoothly disappear when intersecting with
/// geometry in the depth buffer.
#macro BBMOD_U_SOFT_DISTANCE "bbmod_SoftDistance"

/// @func bbmod_shader_set_soft_distance(_shader, _value)
///
/// @desc Sets the {@link BBMOD_U_SOFT_DISTANCE} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Real} _value The new soft distance value.
function bbmod_shader_set_soft_distance(_shader, _value)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_SOFT_DISTANCE),
		_value);
}

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

/// @func bbmod_shader_set_fog(_shader[, _color[, _intensity[, _start[, _end]]]])
///
/// @desc Sets uniforms {@link BBMOD_U_FOG_COLOR}, {@link BBMOD_U_FOG_INTENSITY},
/// {@link BBMOD_U_FOG_START} and {@link BBMOD_U_FOG_RCP_RANGE}.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Struct.BBMOD_Color} [_color] The color of the fog. If `undefined`,
/// then the value set by {@link bbmod_fog_set_color} is used.
/// @param {Real} [_intensity] The fog intensity. If `undefined`, then the
/// value set by {@link bbmod_fog_set_intensity} is used.
/// @param {Real} [_start] The distance at which the fog starts. If
/// `undefined`, then the value set by {@link bbmod_fog_set_start} is used.
/// @param {Real} [_end] The distance at which the fog has maximum intensity.
/// If `undefined`, then the value set by {@link bbmod_fog_set_end} is used.
function bbmod_shader_set_fog(_shader, _color=undefined, _intensity=undefined, _start=undefined, _end=undefined)
{
	gml_pragma("forceinline");
	_color ??= bbmod_fog_get_color();
	_intensity ??= bbmod_fog_get_intensity();
	_start ??= bbmod_fog_get_start();
	_end ??= bbmod_fog_get_end();
	var _rcpFogRange = 1.0 / (_end - _start);
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_FOG_COLOR),
		_color.Red / 255.0,
		_color.Green / 255.0,
		_color.Blue / 255.0,
		_color.Alpha);
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_FOG_INTENSITY),
		_intensity);
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_FOG_START),
		_start);
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_FOG_RCP_RANGE),
		_rcpFogRange);
}

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

/// @func bbmod_shader_set_ambient_light(_shader[, _up[, _down[, _dir[, _isLightmapped]]]])
///
/// @desc Sets the {@link BBMOD_U_LIGHT_AMBIENT_UP}, {@link BBMOD_U_LIGHT_AMBIENT_DOWN}
/// and {@link BBMOD_U_LIGHT_AMBIENT_DIR_UP} uniforms.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Struct.BBMOD_Color} [_up] Ambient light color on the upper
/// hemisphere. If `undefined`, then the value set by
/// {@link bbmod_light_ambient_set_up} is used.
/// @param {Struct.BBMOD_Color} [_down] Ambient light color on the lower
/// hemisphere. If `undefined`, then the value set by
/// {@link bbmod_light_ambient_set_down} is used.
/// @param {Struct.BBMOD_Vec3} [_dir] Direction to the ambient light's upper
/// hemisphere. If `undefined`, then the value set by
/// {@link bbmod_light_ambient_set_dir} is used.
/// @param {Bool} [_isLightmapped] Use `true` in case the shader renders
/// lightmapped models. Defaults to `false.`
function bbmod_shader_set_ambient_light(_shader, _up=undefined, _down=undefined, _dir=undefined, _isLightmapped=false)
{
	gml_pragma("forceinline");
	if (!_isLightmapped || bbmod_light_ambient_get_affect_lightmaps())
	{
		_up ??= bbmod_light_ambient_get_up();
		_down ??= bbmod_light_ambient_get_down();
		_dir ??= bbmod_light_ambient_get_dir();
		shader_set_uniform_f(
			shader_get_uniform(_shader, BBMOD_U_LIGHT_AMBIENT_UP),
			_up.Red / 255.0,
			_up.Green / 255.0,
			_up.Blue / 255.0,
			_up.Alpha);
		shader_set_uniform_f(
			shader_get_uniform(_shader, BBMOD_U_LIGHT_AMBIENT_DOWN),
			_down.Red / 255.0,
			_down.Green / 255.0,
			_down.Blue / 255.0,
			_down.Alpha);
		shader_set_uniform_f(
			shader_get_uniform(_shader, BBMOD_U_LIGHT_AMBIENT_DIR_UP),
			_dir.X,
			_dir.Y,
			_dir.Z);
	}
	else
	{
		shader_set_uniform_f(shader_get_uniform(_shader, BBMOD_U_LIGHT_AMBIENT_UP), 0.0, 0.0, 0.0, 0.0);
		shader_set_uniform_f(shader_get_uniform(_shader, BBMOD_U_LIGHT_AMBIENT_DOWN), 0.0, 0.0, 0.0, 0.0);
		//shader_set_uniform_f(shader_get_uniform(_shader, BBMOD_U_LIGHT_AMBIENT_DIR_UP), 0.0, 0.0, 0.0);
	}
}

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

/// @func bbmod_shader_set_directional_light(_shader[, _light[, _isLightmapped])
///
/// @desc Sets uniforms {@link BBMOD_U_LIGHT_DIRECTIONAL_DIR} and
/// {@link BBMOD_U_LIGHT_DIRECTIONAL_COLOR}.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Struct.BBMOD_DirectionalLight} [_light] The directional light.
/// If `undefined`, then the value set by {@link bbmod_light_directional_set}
/// is used. If the light is not enabled then it is not passed.
/// @param {Bool} [_isLightmapped] Use `true` in case the shader renders
/// lightmapped models. Defaults to `false.`
///
/// @see BBMOD_DirectionalLight
function bbmod_shader_set_directional_light(_shader, _light=undefined, _isLightmapped=false)
{
	gml_pragma("forceinline");
	_light ??= bbmod_light_directional_get();
	if (_light != undefined
		&& _light.Enabled
		&& (!_isLightmapped || _light.AffectLightmaps))
	{
		var _direction = _light.Direction;
		shader_set_uniform_f(
			shader_get_uniform(_shader, BBMOD_U_LIGHT_DIRECTIONAL_DIR),
			_direction.X,
			_direction.Y,
			_direction.Z);
		var _color = _light.Color;
		shader_set_uniform_f(
			shader_get_uniform(_shader, BBMOD_U_LIGHT_DIRECTIONAL_COLOR),
			_color.Red / 255.0,
			_color.Green / 255.0,
			_color.Blue / 255.0,
			_color.Alpha);
	}
	else
	{
		shader_set_uniform_f(shader_get_uniform(_shader, BBMOD_U_LIGHT_DIRECTIONAL_DIR), 0.0, 0.0, -1.0);
		shader_set_uniform_f(shader_get_uniform(_shader, BBMOD_U_LIGHT_DIRECTIONAL_COLOR), 0.0, 0.0, 0.0, 0.0);
	}
}

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds the screen-space ambient occlusion texture.
#macro BBMOD_U_SSAO "bbmod_SSAO"

/// @func bbmod_shader_set_ssao(_shader, _ssao)
///
/// @desc Sets the {@link BBMOD_U_SSAO} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Pointer.Texture} _ssao The new SSAO texture.
function bbmod_shader_set_ssao(_shader, _ssao)
{
	gml_pragma("forceinline");
	texture_set_stage(
		shader_get_sampler_index(_shader, BBMOD_U_SSAO),
		_ssao);
}

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

/// @func bbmod_shader_set_ibl(_shader[, _ibl[, _isLightmapped]])
///
/// @desc Sets a fragment shader uniforms {@link BBMOD_U_IBL_ENABLE},
/// {@link BBMOD_U_IBL_TEXEL} and {@link BBMOD_U_IBL}. These are required for
/// image based lighting.
///
/// @param {Asset.GMShader} _shader The shader to set the uniforms for.
/// @param {Struct.BBMOD_ImageBasedLight} [_ibl] The image based light.
/// If `undefined`, then the value set by {@link bbmod_ibl_set} is used. If
/// the light is not enabled, then it is not passed.
/// @param {Bool} [_isLightmapped] Use `true` in case the shader renders
/// lightmapped models. Defaults to `false.`
function bbmod_shader_set_ibl(_shader, _ibl=undefined, _isLightmapped=false)
{
	gml_pragma("forceinline");

		var _texture = pointer_null;
		var _texel;

		_ibl ??= bbmod_ibl_get();

		if (_ibl != undefined
			&& _ibl.Enabled
			&& (!_isLightmapped || _ibl.AffectLightmaps))
		{
			_texture = _ibl.Texture;
			_texel = _ibl.Texel;
		}

		if (global.__bbmodReflectionProbeTexture != pointer_null)
		{
			_texture = global.__bbmodReflectionProbeTexture;
			_texel = texture_get_texel_height(_texture);
		}

		if (_texture != pointer_null)
		{
			var _uIBL = shader_get_sampler_index(_shader, BBMOD_U_IBL);

			texture_set_stage(_uIBL, _texture);
			gpu_set_tex_mip_enable_ext(_uIBL, mip_off)
			gpu_set_tex_filter_ext(_uIBL, true);
			gpu_set_tex_repeat_ext(_uIBL, false);
			shader_set_uniform_f(
				shader_get_uniform(_shader, BBMOD_U_IBL_TEXEL),
				_texel, _texel);
			shader_set_uniform_f(
				shader_get_uniform(_shader, BBMOD_U_IBL_ENABLE),
				1.0);
		}
		else
		{
			shader_set_uniform_f(
				shader_get_uniform(_shader, BBMOD_U_IBL_ENABLE),
				0.0);
		}
}

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

/// @func bbmod_shader_set_punctual_lights(_shader[, _lights[, _isLightmapped]])
///
/// @desc Sets uniforms {@link BBMOD_U_LIGHT_PUNCTUAL_DATA_A} and
/// {@link BBMOD_U_LIGHT_PUNCTUAL_DATA_B}.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Array<Struct.BBMOD_PunctualLight>} [_lights] An array of punctual
/// lights. If `undefined`, then the lights defined using
/// {@link bbmod_light_punctual_add} are passed. Only enabled lights will be used!
/// @param {Bool} [_isLightmapped] Use `true` in case the shader renders
/// lightmapped models. Defaults to `false.`
function bbmod_shader_set_punctual_lights(_shader, _lights=undefined, _isLightmapped=false)
{
	gml_pragma("forceinline");

	_lights ??= bbmod_scene_get_current().LightsPunctual;

	var _renderPassMask = (1 << bbmod_render_pass_get());

	var _indexA = 0;
	var _indexMaxA = BBMOD_MAX_PUNCTUAL_LIGHTS * 8;
	var _dataA = array_create(_indexMaxA, 0.0);

	var _indexB = 0;
	var _indexMaxB = BBMOD_MAX_PUNCTUAL_LIGHTS * 6;
	var _dataB = array_create(_indexMaxB, 0.0);

	var i = 0;

	repeat (array_length(_lights))
	{
		var _light = _lights[i++];

		if (_light.Enabled
			&& (_light.RenderPass & _renderPassMask) != 0
			&& (!_isLightmapped || _light.AffectLightmaps))
		{
			_light.Position.ToArray(_dataA, _indexA);
			_dataA[@ _indexA + 3] = _light.Range;
			var _color = _light.Color;
			_dataA[@ _indexA + 4] = _color.Red / 255.0;
			_dataA[@ _indexA + 5] = _color.Green / 255.0;
			_dataA[@ _indexA + 6] = _color.Blue / 255.0;
			_dataA[@ _indexA + 7] = _color.Alpha;
			_indexA += 8;

			if (is_instanceof(_light, BBMOD_SpotLight))
			{
				_dataB[@ _indexB] = 1.0;
				_dataB[@ _indexB + 1] = dcos(_light.AngleInner);
				_dataB[@ _indexB + 2] = dcos(_light.AngleOuter);
				_light.Direction.ToArray(_dataB, _indexB + 3);
			}
			_indexB += 6;

			if (_indexA >= _indexMaxA)
			{
				break;
			}
		}
	}

	shader_set_uniform_f_array(
		shader_get_uniform(_shader, BBMOD_U_LIGHT_PUNCTUAL_DATA_A),
		_dataA);
	shader_set_uniform_f_array(
		shader_get_uniform(_shader, BBMOD_U_LIGHT_PUNCTUAL_DATA_B),
		_dataB);
}

/// @macro {String} Common part of uniform names {@link BBMOD_U_TERRAIN_BASE_OPACITY_0},
/// {@link BBMOD_U_TERRAIN_BASE_OPACITY_1} and {@link BBMOD_U_TERRAIN_BASE_OPACITY_2},
/// which only append a number to it.
#macro BBMOD_U_TERRAIN_BASE_OPACITY "bbmod_TerrainBaseOpacity"

/// @macro {String} Common part of uniform names {@link BBMOD_U_TERRAIN_NORMAL_W_0},
/// {@link BBMOD_U_TERRAIN_NORMAL_W_1} and {@link BBMOD_U_TERRAIN_NORMAL_W_2},
/// which only append a number to it.
#macro BBMOD_U_TERRAIN_NORMAL_W "bbmod_TerrainNormalW"

/// @macro {String} Common part of uniform names {@link BBMOD_U_TERRAIN_IS_ROUGHNESS_0},
/// {@link BBMOD_U_TERRAIN_IS_ROUGHNESS_1} and {@link BBMOD_U_TERRAIN_IS_ROUGHNESS_2},
/// which only append a number to it.
#macro BBMOD_U_TERRAIN_IS_ROUGHNESS "bbmod_TerrainIsRoughness"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with base color in RGB channels and opacity in the A channel
/// for the first terrain layer rendered in a single draw call.
#macro BBMOD_U_TERRAIN_BASE_OPACITY_0 "gm_BaseTexture"

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds normal smoothness/roughness texture for the first terrain layer rendered
/// in a single draw call.
#macro BBMOD_U_TERRAIN_NORMAL_W_0     (BBMOD_U_TERRAIN_NORMAL_W + "0")

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// whether the first terrain material layer uses roughness workflow (1.0) or not (0.0).
#macro BBMOD_U_TERRAIN_IS_ROUGHNESS_0 (BBMOD_U_TERRAIN_IS_ROUGHNESS + "0")

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with base color in RGB channels and opacity in the A channel
/// for the second terrain layer rendered in a single draw call.
#macro BBMOD_U_TERRAIN_BASE_OPACITY_1 (BBMOD_U_TERRAIN_BASE_OPACITY + "1")

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds normal smoothness/roughness texture for the second terrain layer rendered
/// in a single draw call.
#macro BBMOD_U_TERRAIN_NORMAL_W_1     (BBMOD_U_TERRAIN_NORMAL_W + "1")

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// whether the second terrain material layer uses roughness workflow (1.0) or not (0.0).
#macro BBMOD_U_TERRAIN_IS_ROUGHNESS_1 (BBMOD_U_TERRAIN_IS_ROUGHNESS + "1")

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds a texture with base color in RGB channels and opacity in the A channel
/// for the third terrain layer rendered in a single draw call.
#macro BBMOD_U_TERRAIN_BASE_OPACITY_2 (BBMOD_U_TERRAIN_BASE_OPACITY + "2")

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds normal smoothness/roughness texture for the third terrain layer rendered
/// in a single draw call.
#macro BBMOD_U_TERRAIN_NORMAL_W_2     (BBMOD_U_TERRAIN_NORMAL_W + "2")

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// whether the third terrain material layer uses roughness workflow (1.0) or not (0.0).
#macro BBMOD_U_TERRAIN_IS_ROUGHNESS_2 (BBMOD_U_TERRAIN_IS_ROUGHNESS + "2")

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds the splatmap texture.
#macro BBMOD_U_SPLATMAP "bbmod_Splatmap"

/// @macro {String} Common part of uniform names {@link BBMOD_U_SPLATMAP_INDEX_0},
/// {@link BBMOD_U_SPLATMAP_INDEX_1} and {@link BBMOD_U_SPLATMAP_INDEX_2},
/// which only append a number to it.
#macro BBMOD_U_SPLATMAP_INDEX "bbmod_SplatmapIndex"

/// @macro {String} Name of a fragment shader uniform of type `int` that holds
/// the index of a channel to read from the splatmap for the first terrain layer
/// rendered in a draw call.
#macro BBMOD_U_SPLATMAP_INDEX_0 (BBMOD_U_SPLATMAP_INDEX + "0")

/// @macro {String} Name of a fragment shader uniform of type `int` that holds
/// the index of a channel to read from the splatmap for the second terrain layer
/// rendered in a draw call.
#macro BBMOD_U_SPLATMAP_INDEX_1 (BBMOD_U_SPLATMAP_INDEX + "1")

/// @macro {String} Name of a fragment shader uniform of type `int` that holds
/// the index of a channel to read from the splatmap for the third terrain layer
/// rendered in a draw call.
#macro BBMOD_U_SPLATMAP_INDEX_2 (BBMOD_U_SPLATMAP_INDEX + "2")

/// @macro {String} Name of a fragment shader uniform of type `sampler2D` that
/// holds the colormap texture.
#macro BBMOD_U_COLORMAP "bbmod_Colormap"

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

/// @func bbmod_shader_set_shadowmap_bias(_shader, _bias)
///
/// @desc Sets the {@link BBMOD_U_SHADOWMAP_BIAS} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Real} _bias The new shadowmap bias value.
function bbmod_shader_set_shadowmap_bias(_shader, _bias)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_SHADOWMAP_BIAS),
		_bias);
}

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// the index of a punctual light that casts shadows or -1.0, if it's the
/// directional light.
#macro BBMOD_U_SHADOW_CASTER_INDEX "bbmod_ShadowCasterIndex"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// how much are vertices offset by their normal before they are transformed into
/// shadowmap-space, using formula `vertex + normal * normalOffset`.
#macro BBMOD_U_SHADOWMAP_NORMAL_OFFSET_PS "bbmod_ShadowmapNormalOffsetPS"

/// @macro {String} Name of a fragment shader uniform of type `float` that holds
/// whether HDR rendering is enabled (1.0) or not (0.0).
/// @see bbmod_hdr_is_supported
#macro BBMOD_U_HDR "bbmod_HDR"

/// @funct bbmod_shader_set_hdr(_shader, _hdr)
///
/// @desc Sets the {@link BBMOD_U_HDR} uniform.
///
/// @param {Asset.GMShader} _shader The shader to set the uniform for.
/// @param {Bool} _hdr Use `true` when rendering into floating point surfaces.
function bbmod_shader_set_hdr(_shader, _hdr)
{
	gml_pragma("forceinline");
	shader_set_uniform_f(
		shader_get_uniform(_shader, BBMOD_U_HDR),
		_hdr ? 1.0 : 0.0);
}
