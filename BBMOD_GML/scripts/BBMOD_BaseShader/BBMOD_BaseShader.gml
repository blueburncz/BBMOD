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
///
/// @see BBMOD_VertexFormat
function BBMOD_BaseShader(_shader, _vertexFormat)
	: BBMOD_Shader(_shader, _vertexFormat) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

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
	static set_texture_offset = function (_offset)
	{
		gml_pragma("forceinline");
		shader_set_uniform_f(
			shader_get_uniform(shader_current(), BBMOD_U_TEXTURE_OFFSET),
			_offset.X, _offset.Y);
		return self;
	};

	/// @func set_texture_scale(_scale)
	///
	/// @desc Sets the {@link BBMOD_U_TEXTURE_SCALE} uniform to the given scale.
	///
	/// @param {Struct.BBMOD_Vec2} _scale The texture scale.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_texture_scale = function (_scale)
	{
		gml_pragma("forceinline");
		shader_set_uniform_f(
			shader_get_uniform(shader_current(), BBMOD_U_TEXTURE_SCALE),
			_scale.X, _scale.Y);
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
	static set_bones = function (_bones)
	{
		gml_pragma("forceinline");
		shader_set_uniform_f_array(
			shader_get_uniform(shader_current(), BBMOD_U_BONES),
			_bones);
		return self;
	};

	/// @func set_batch_data(_data)
	///
	/// @desc Sets the {@link BBMOD_U_BATCH_DATA} uniform.
	///
	/// @param {Array<Real>} _data The dynamic batch data.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_batch_data = function (_data)
	{
		gml_pragma("forceinline");
		shader_set_uniform_f_array(
			shader_get_uniform(shader_current(), BBMOD_U_BATCH_DATA),
			_data);
		return self;
	};

	/// @func set_alpha_test(_value)
	///
	/// @desc Sets the {@link BBMOD_U_ALPHA_TEST} uniform.
	///
	/// @param {Real} _value The alpha test value.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_alpha_test = function (_value)
	{
		gml_pragma("forceinline");
		shader_set_uniform_f(
			shader_get_uniform(shader_current(), BBMOD_U_ALPHA_TEST),
			_value);
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
	static set_cam_pos = function (_pos=undefined)
	{
		gml_pragma("forceinline");
		_pos ??= global.__bbmodCameraPosition;
		shader_set_uniform_f(
			shader_get_uniform(shader_current(), BBMOD_U_CAM_POS),
			_pos.X, _pos.Y, _pos.Z);
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
	static set_exposure = function (_value=undefined)
	{
		gml_pragma("forceinline");
		shader_set_uniform_f(
			shader_get_uniform(shader_current(), BBMOD_U_EXPOSURE),
			_value ?? global.__bbmodCameraExposure);
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
	static set_instance_id = function (_id=undefined)
	{
		gml_pragma("forceinline");
		_id ??= global.__bbmodInstanceID;
		shader_set_uniform_f(
			shader_get_uniform(shader_current(), BBMOD_U_INSTANCE_ID),
			((_id & $000000FF) >> 0) / 255,
			((_id & $0000FF00) >> 8) / 255,
			((_id & $00FF0000) >> 16) / 255,
			((_id & $FF000000) >> 24) / 255);
		return self;
	};

	/// @func set_material_index(_index)
	///
	/// @desc Sets the {@link BBMOD_U_MATERIAL_INDEX} uniform.
	///
	/// @param {Real} [_index] The index of the current material.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	static set_material_index = function (_index)
	{
		gml_pragma("forceinline");
		shader_set_uniform_f(
			shader_get_uniform(shader_current(), BBMOD_U_MATERIAL_INDEX),
			_index);
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
	static set_ibl = function (_ibl=undefined)
	{
		gml_pragma("forceinline");

		var _texture = pointer_null;
		var _texel;

		_ibl ??= global.__bbmodImageBasedLight;

		if (_ibl != undefined && _ibl.Enabled)
		{
			_texture = _ibl.Texture;
			_texel = _ibl.Texel;
		}

		if (global.__bbmodReflectionProbeTexture != pointer_null)
		{
			_texture = global.__bbmodReflectionProbeTexture;
			_texel = texture_get_texel_height(_texture);
		}

		var _shaderCurrent = shader_current();

		if (_texture != pointer_null)
		{
			var _uIBL = shader_get_sampler_index(_shaderCurrent, BBMOD_U_IBL);

			texture_set_stage(_uIBL, _texture);
			gpu_set_tex_mip_enable_ext(_uIBL, mip_off)
			gpu_set_tex_filter_ext(_uIBL, true);
			gpu_set_tex_repeat_ext(_uIBL, false);
			shader_set_uniform_f(
				shader_get_uniform(_shaderCurrent, BBMOD_U_IBL_TEXEL),
				_texel, _texel);
			shader_set_uniform_f(
				shader_get_uniform(_shaderCurrent, BBMOD_U_IBL_ENABLE),
				1.0);
		}
		else
		{
			shader_set_uniform_f(
				shader_get_uniform(_shaderCurrent, BBMOD_U_IBL_ENABLE),
				0.0);
		}

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
	static set_ambient_light = function (_up=undefined, _down=undefined, _dir=undefined)
	{
		gml_pragma("forceinline");
		_up ??= global.__bbmodAmbientLightUp;
		_down ??= global.__bbmodAmbientLightDown;
		_dir ??= global.__bbmodAmbientLightDirUp;
		var _shaderCurrent = shader_current();
		shader_set_uniform_f(
			shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_AMBIENT_UP),
			_up.Red / 255.0, _up.Green / 255.0, _up.Blue / 255.0, _up.Alpha);
		shader_set_uniform_f(
			shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_AMBIENT_DOWN),
			_down.Red / 255.0, _down.Green / 255.0, _down.Blue / 255.0, _down.Alpha);
		shader_set_uniform_f(
			shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_AMBIENT_DIR_UP),
			_dir.X, _dir.Y, _dir.Z);
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
	static set_directional_light = function (_light=undefined)
	{
		gml_pragma("forceinline");
		_light ??= global.__bbmodDirectionalLight;
		var _shaderCurrent = shader_current();
		var _uLightDirectionalDir = shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_DIRECTIONAL_DIR);
		var _uLightDirectionalColor = shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_DIRECTIONAL_COLOR);
		if (_light != undefined	&& _light.Enabled)
		{
			var _direction = _light.Direction;
			shader_set_uniform_f(_uLightDirectionalDir,
				_direction.X, _direction.Y, _direction.Z);
			var _color = _light.Color;
			shader_set_uniform_f(_uLightDirectionalColor,
				_color.Red / 255.0,
				_color.Green / 255.0,
				_color.Blue / 255.0,
				_color.Alpha);
		}
		else
		{
			shader_set_uniform_f(_uLightDirectionalDir, 0.0, 0.0, -1.0);
			shader_set_uniform_f(_uLightDirectionalColor, 0.0, 0.0, 0.0, 0.0);
		}
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
	/// @deprecated Please use {@link set_punctual_lights} instead.
	static set_point_lights = function (_lights=undefined)
	{
		gml_pragma("forceinline");
		set_punctual_lights(_lights);
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
	static set_punctual_lights = function (_lights=undefined)
	{
		gml_pragma("forceinline");

		_lights ??= global.__bbmodPunctualLights;

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

			if (_light.Enabled)
			{
				_light.Position.ToArray(_dataA, _indexA);
				_dataA[@ _indexA + 3] = _light.Range;
				var _color = _light.Color;
				_dataA[@ _indexA + 4] = _color.Red / 255.0;
				_dataA[@ _indexA + 5] = _color.Green / 255.0;
				_dataA[@ _indexA + 6] = _color.Blue / 255.0;
				_dataA[@ _indexA + 7] = _color.Alpha;
				_indexA += 8;

				if (_light.is_instance(BBMOD_SpotLight)) // Ugh, but works!
				{
					_dataB[@ _indexB] = 1.0; // Is spot light
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

		var _shaderCurrent = shader_current();

		shader_set_uniform_f_array(
			shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_PUNCTUAL_DATA_A),
			_dataA);
		shader_set_uniform_f_array(
			shader_get_uniform(_shaderCurrent, BBMOD_U_LIGHT_PUNCTUAL_DATA_B),
			_dataB);

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
	static set_fog = function (_color=undefined, _intensity=undefined, _start=undefined, _end=undefined)
	{
		gml_pragma("forceinline");
		_color ??= global.__bbmodFogColor;
		_intensity ??= global.__bbmodFogIntensity;
		_start ??= global.__bbmodFogStart;
		_end ??= global.__bbmodFogEnd;
		var _rcpFogRange = 1.0 / (_end - _start);
		var _shaderCurrent = shader_current();
		shader_set_uniform_f(
			shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_COLOR),
			_color.Red / 255.0,
			_color.Green / 255.0,
			_color.Blue / 255.0,
			_color.Alpha);
		shader_set_uniform_f(
			shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_INTENSITY),
			_intensity);
		shader_set_uniform_f(
			shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_START),
			_start);
		shader_set_uniform_f(
			shader_get_uniform(_shaderCurrent, BBMOD_U_FOG_RCP_RANGE),
			_rcpFogRange);
		return self;
	};

	static on_set = function ()
	{
		gml_pragma("forceinline");
		set_cam_pos();
		set_exposure();
		set_ibl();
		set_ambient_light();
		set_directional_light();
		set_punctual_lights();
		set_fog();
		texture_set_stage(
			shader_get_sampler_index(shader_current(), BBMOD_U_SSAO),
			sprite_get_texture(BBMOD_SprWhite, 0));
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
		shader_set_uniform_f(
			shader_get_uniform(_shaderCurrent, BBMOD_U_BASE_OPACITY_MULTIPLIER),
			_material.BaseOpacityMultiplier.Red / 255.0,
			_material.BaseOpacityMultiplier.Green / 255.0,
			_material.BaseOpacityMultiplier.Blue / 255.0,
			_material.BaseOpacityMultiplier.Alpha);
		set_alpha_test(_material.AlphaTest);
		set_texture_offset(_material.TextureOffset);
		set_texture_scale(_material.TextureScale);
		shader_set_uniform_f(
			shader_get_uniform(_shaderCurrent, BBMOD_U_SHADOWMAP_BIAS),
			_material.ShadowmapBias);
		return self;
	};
}
