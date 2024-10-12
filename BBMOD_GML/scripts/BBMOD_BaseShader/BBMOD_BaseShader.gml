/// @module Core

/// @macro {Real} Maximum number of punctual lights in shaders. Equals to 8.
#macro BBMOD_MAX_PUNCTUAL_LIGHTS 8

/// @func BBMOD_BaseShader(_shader, _vertexFormat)
///
/// @extends BBMOD_Shader
///
/// @desc Base class for BBMOD shaders.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
function BBMOD_BaseShader(_shader, _vertexFormat): BBMOD_Shader(_shader, _vertexFormat) constructor
{
	/// @var {Real} Maximum number of punctual lights in the shader.
	/// @deprecated Please use {@link BBMOD_MAX_PUNCTUAL_LIGHTS} instead.
	/// @readonly
	MaxPunctualLights = BBMOD_MAX_PUNCTUAL_LIGHTS;

	/// @func set_texture_offset(_offset)
	///
	/// @desc Sets the {@link BBMOD_U_TEXTURE_OFFSET} uniform to the given offset.
	///
	/// @param {Struct.BBMOD_Vec2} _offset The texture offset.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_texture_offset} instead.
	static set_texture_offset = function (_offset)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_texture_offset(shader_current(), _offset);
		return self;
	};

	/// @func set_texture_scale(_scale)
	///
	/// @desc Sets the {@link BBMOD_U_TEXTURE_SCALE} uniform to the given scale.
	///
	/// @param {Struct.BBMOD_Vec2} _scale The texture scale.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_texture_scale} instead.
	static set_texture_scale = function (_scale)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_texture_scale(shader_current(), _scale);
		return self;
	};

	/// @func set_bones(_bones)
	///
	/// @desc Sets the {@link BBMOD_U_BONES} uniform.
	///
	/// @param {Array<Real>} _bones The array of bone transforms.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_AnimationPlayer.get_transform
	///
	/// @deprecated Please use {@link bbmod_shader_set_bones} instead.
	static set_bones = function (_bones)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_bones(shader_current(), _bones);
		return self;
	};

	/// @func set_batch_data(_data)
	///
	/// @desc Sets the {@link BBMOD_U_BATCH_DATA} uniform.
	///
	/// @param {Array<Real>} _data The dynamic batch data.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_batch_data} instead.
	static set_batch_data = function (_data)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_batch_data(shader_current(), _data);
		return self;
	};

	/// @func set_alpha_test(_value)
	///
	/// @desc Sets the {@link BBMOD_U_ALPHA_TEST} uniform.
	///
	/// @param {Real} _value The alpha test value.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_alpha_test} instead.
	static set_alpha_test = function (_value)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_alpha_test(shader_current(), _value);
		return self;
	};

	/// @func set_cam_pos([_pos])
	///
	/// @desc Sets a fragment shader uniform {@link BBMOD_U_CAM_POS} to the given position.
	///
	/// @param {Struct.BBMOD_Vec3} [_pos] The camera position. If `undefined`,
	/// then the value set by {@link bbmod_camera_set_position} is used.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_cam_pos} instead.
	static set_cam_pos = function (_pos = undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_cam_pos(shader_current(), _pos);
		return self;
	};

	/// @func set_exposure([_value])
	///
	/// @desc Sets the {@link BBMOD_U_EXPOSURE} uniform.
	///
	/// @param {Real} [_value] The camera exposure. If `undefined`,
	/// then the value set by {@link bbmod_camera_set_exposure} is used.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_exposure} instead.
	static set_exposure = function (_value = undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_exposure(shader_current(), _value);
		return self;
	};

	/// @func set_instance_id([_id])
	///
	/// @desc Sets the {@link BBMOD_U_INSTANCE_ID} uniform.
	///
	/// @param {Id.Instance} [_id] The instance ID. If `undefined`,
	/// then the value set by {@link bbmod_set_instance_id} is used.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_instance_id} instead.
	static set_instance_id = function (_id = undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_instance_id(shader_current(), _id);
		return self;
	};

	/// @func set_material_index(_index)
	///
	/// @desc Sets the {@link BBMOD_U_MATERIAL_INDEX} uniform.
	///
	/// @param {Real} [_index] The index of the current material.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_material_index} instead.
	static set_material_index = function (_index)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_material_index(shader_current(), _index);
		return self;
	};

	/// @func set_ibl([_ibl])
	///
	/// @desc Sets a fragment shader uniforms {@link BBMOD_U_IBL_ENABLE},
	/// {@link BBMOD_U_IBL_TEXEL} and {@link BBMOD_U_IBL}. These are required for
	/// image based lighting.
	///
	/// @param {Struct.BBMOD_ImageBasedLight} [_ibl] The image based light.
	/// If `undefined`, then the value set by {@link bbmod_ibl_set} is used. If
	/// the light is not enabled, then it is not passed.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_ibl} instead.
	static set_ibl = function (_ibl = undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_ibl(shader_current(), _ibl);
		return self;
	};

	/// @func set_ambient_light([_up[, _down[, _dir]]])
	///
	/// @desc Sets the {@link BBMOD_U_LIGHT_AMBIENT_UP}, {@link BBMOD_U_LIGHT_AMBIENT_DOWN}
	/// and {@link BBMOD_U_LIGHT_AMBIENT_DIR_UP} uniforms.
	///
	/// @param {Struct.BBMOD_Color} [_up] Ambient light color on the upper
	/// hemisphere. If `undefined`, then the value set by
	/// {@link bbmod_light_ambient_set_up} is used.
	/// @param {Struct.BBMOD_Color} [_down] Ambient light color on the lower
	/// hemisphere. If `undefined`, then the value set by
	/// {@link bbmod_light_ambient_set_down} is used.
	/// @param {Struct.BBMOD_Vec3} [_dir] Direction to the ambient light's upper
	/// hemisphere. If `undefined`, then the value set by
	/// {@link bbmod_light_ambient_set_dir} is used.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_ambient_light} instead.
	static set_ambient_light = function (_up = undefined, _down = undefined, _dir = undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_ambient_light(shader_current(), _up, _down, _dir);
		return self;
	};

	/// @func set_directional_light([_light])
	///
	/// @desc Sets uniforms {@link BBMOD_U_LIGHT_DIRECTIONAL_DIR} and
	/// {@link BBMOD_U_LIGHT_DIRECTIONAL_COLOR}.
	///
	/// @param {Struct.BBMOD_DirectionalLight} [_light] The directional light.
	/// If `undefined`, then the value set by {@link bbmod_light_directional_set}
	/// is used. If the light is not enabled then it is not passed.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	///
	/// @see BBMOD_DirectionalLight
	///
	/// @deprecated Please use {@link bbmod_shader_set_directional_light} instead.
	static set_directional_light = function (_light = undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_directional_light(shader_current(), _light);
		return self;
	};

	/// @func set_point_lights([_lights])
	///
	/// @desc Sets uniforms {@link BBMOD_U_LIGHT_PUNCTUAL_DATA_A} and
	/// {@link BBMOD_U_LIGHT_PUNCTUAL_DATA_B}.
	///
	/// @param {Array<Struct.BBMOD_PointLight>} [_lights] An array of point
	/// lights. If `undefined`, then the lights defined using
	/// {@link bbmod_light_point_add} are passed. Only enabled lights will be used!
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_punctual_lights} instead.
	static set_point_lights = function (_lights = undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_punctual_lights(shader_current(), _lights);
		return self;
	};

	/// @func set_punctual_lights([_lights])
	///
	/// @desc Sets uniforms {@link BBMOD_U_LIGHT_PUNCTUAL_DATA_A} and
	/// {@link BBMOD_U_LIGHT_PUNCTUAL_DATA_B}.
	///
	/// @param {Array<Struct.BBMOD_PunctualLight>} [_lights] An array of punctual
	/// lights. If `undefined`, then the lights defined using
	/// {@link bbmod_light_punctual_add} are passed. Only enabled lights will be used!
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_punctual_lights} instead.
	static set_punctual_lights = function (_lights = undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_punctual_lights(shader_current(), _lights);
		return self;
	};

	/// @func set_fog([_color[, _intensity[, _start[, _end]]]])
	///
	/// @desc Sets uniforms {@link BBMOD_U_FOG_COLOR}, {@link BBMOD_U_FOG_INTENSITY},
	/// {@link BBMOD_U_FOG_START} and {@link BBMOD_U_FOG_RCP_RANGE}.
	///
	/// @param {Struct.BBMOD_Color} [_color] The color of the fog. If `undefined`,
	/// then the value set by {@link bbmod_fog_set_color} is used.
	/// @param {Real} [_intensity] The fog intensity. If `undefined`, then the
	/// value set by {@link bbmod_fog_set_intensity} is used.
	/// @param {Real} [_start] The distance at which the fog starts. If
	/// `undefined`, then the value set by {@link bbmod_fog_set_start} is used.
	/// @param {Real} [_end] The distance at which the fog has maximum intensity.
	/// If `undefined`, then the value set by {@link bbmod_fog_set_end} is used.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	///
	/// @deprecated Please use {@link bbmod_shader_set_fog} instead.
	static set_fog = function (_color = undefined, _intensity = undefined, _start = undefined, _end = undefined)
	{
		gml_pragma("forceinline");
		bbmod_shader_set_fog(shader_current(), _color, _intensity, _start, _end);
		return self;
	};

	static on_set = function ()
	{
		gml_pragma("forceinline");
		var _shaderCurrent = shader_current();
		bbmod_shader_set_cam_pos(_shaderCurrent);
		bbmod_shader_set_exposure(_shaderCurrent);
		bbmod_shader_set_ibl(_shaderCurrent);
		bbmod_shader_set_ambient_light(_shaderCurrent);
		bbmod_shader_set_directional_light(_shaderCurrent);
		bbmod_shader_set_punctual_lights(_shaderCurrent);
		bbmod_shader_set_fog(_shaderCurrent);
		bbmod_shader_set_ssao(_shaderCurrent, sprite_get_texture(BBMOD_SprWhite, 0));
		bbmod_shader_set_hdr(_shaderCurrent, 0.0);
	};

	/// @func set_material(_material)
	///
	/// @desc Sets shader uniforms using values from the material.
	/// @param {Struct.BBMOD_BaseMaterial} _material The material to take the
	/// values from.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	///
	/// @see BBMOD_BaseMaterial
	static set_material = function (_material)
	{
		gml_pragma("forceinline");
		var _shaderCurrent = shader_current();
		bbmod_shader_set_base_opacity_multiplier(_shaderCurrent, _material.BaseOpacityMultiplier);
		bbmod_shader_set_alpha_test(_shaderCurrent, _material.AlphaTest);
		bbmod_shader_set_texture_offset(_shaderCurrent, _material.TextureOffset);
		bbmod_shader_set_texture_scale(_shaderCurrent, _material.TextureScale);
		bbmod_shader_set_shadowmap_bias(_shaderCurrent, _material.ShadowmapBias);
		bbmod_shader_set_two_sided(_shaderCurrent, _material.TwoSided);
		return self;
	};
}
