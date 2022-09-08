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
	/// @var {Real} Maximum number of point lights in the shader. This must
	/// match with value defined in the raw GameMaker shader!
	MaxPointLights = 8;

	UBaseOpacityMultiplier = get_uniform("bbmod_BaseOpacityMultiplier");

	UTextureOffset = get_uniform("bbmod_TextureOffset");

	UTextureScale = get_uniform("bbmod_TextureScale");

	UBones = get_uniform("bbmod_Bones");

	UBatchData = get_uniform("bbmod_BatchData");

	UAlphaTest = get_uniform("bbmod_AlphaTest");

	UCamPos = get_uniform("bbmod_CamPos");

	UExposure = get_uniform("bbmod_Exposure");

	UInstanceID = get_uniform("bbmod_InstanceID");

	UMaterialIndex = get_uniform("bbmod_MaterialIndex");

	UIBL = get_sampler_index("bbmod_IBL");

	UIBLTexel = get_uniform("bbmod_IBLTexel");

	ULightAmbientUp = get_uniform("bbmod_LightAmbientUp");

	ULightAmbientDown = get_uniform("bbmod_LightAmbientDown");

	ULightDirectionalDir = get_uniform("bbmod_LightDirectionalDir");

	ULightDirectionalColor = get_uniform("bbmod_LightDirectionalColor");

	ULightPointData = get_uniform("bbmod_LightPointData");

	UFogColor = get_uniform("bbmod_FogColor");

	UFogIntensity = get_uniform("bbmod_FogIntensity");

	UFogStart = get_uniform("bbmod_FogStart");

	UFogRcpRange = get_uniform("bbmod_FogRcpRange");

	UShadowmapBias = get_uniform("bbmod_ShadowmapBias");

	USSAO = get_sampler_index("bbmod_SSAO");

	/// @func set_texture_offset(_offset)
	///
	/// @desc Sets the `bbmod_TextureOffset` uniform to the given offset.
	///
	/// @param {Struct.BBMOD_Vec2} _offset The texture offset.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_texture_offset = function (_offset) {
		gml_pragma("forceinline");
		return set_uniform_f2(UTextureOffset, _offset.X, _offset.Y);
	};

	/// @func set_texture_scale(_scale)
	///
	/// @desc Sets the `bbmod_TextureScale` uniform to the given scale.
	///
	/// @param {Struct.BBMOD_Vec2} _scale The texture scale.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_texture_scale = function (_scale) {
		gml_pragma("forceinline");
		return set_uniform_f2(UTextureScale, _scale.X, _scale.Y);
	};

	/// @func set_bones(_bones)
	///
	/// @desc Sets the `bbmod_Bones` uniform.
	///
	/// @param {Array<Real>} _bones The array of bone transforms.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_AnimationPlayer.get_transform
	static set_bones = function (_bones) {
		gml_pragma("forceinline");
		return set_uniform_f_array(UBones, _bones);
	};

	/// @func set_batch_data(_data)
	///
	/// @desc Sets the `bbmod_BatchData` uniform.
	///
	/// @param {Array<Real>} _data The dynamic batch data.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_batch_data = function (_data) {
		gml_pragma("forceinline");
		return set_uniform_f_array(UBatchData, _data);
	};

	/// @func set_alpha_test(_value)
	///
	/// @desc Sets the `bbmod_AlphaTest` uniform.
	///
	/// @param {Real} _value The alpha test value.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_alpha_test = function (_value) {
		gml_pragma("forceinline");
		return set_uniform_f(UAlphaTest, _value);
	};

	/// @func set_cam_pos([_pos])
	///
	/// @desc Sets a fragment shader uniform `bbmod_CamPos` to the given position.
	///
	/// @param {Struct.BBMOD_Vec3} [_pos] The camera position. If `undefined`,
	/// then the value set by {@link bbmod_camera_set_position} is used.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_cam_pos = function (_pos=undefined) {
		gml_pragma("forceinline");
		_pos ??= global.__bbmodCameraPosition;
		return set_uniform_f3(UCamPos, _pos.X, _pos.Y, _pos.Z);
	};

	/// @func set_exposure([_value])
	///
	/// @desc Sets the `bbmod_Exposure` uniform.
	///
	/// @param {Real} [_value] The camera exposure. If `undefined`,
	/// then the value set by {@link bbmod_camera_set_exposure} is used.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	static set_exposure = function (_value=undefined) {
		gml_pragma("forceinline");
		_value ??= global.__bbmodCameraExposure;
		return set_uniform_f(UExposure, _value);
	};

	/// @func set_instance_id([_id])
	///
	/// @desc Sets the `bbmod_InstanceID` uniform.
	///
	/// @param {Id.Instance} [_id] The instance ID. If `undefined`,
	/// then the value set by {@link bbmod_set_instance_id} is used.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	static set_instance_id = function (_id=undefined) {
		gml_pragma("forceinline");
		_id ??= global.__bbmodInstanceID;
		return set_uniform_f4(
			UInstanceID,
			((_id & $000000FF) >> 0) / 255,
			((_id & $0000FF00) >> 8) / 255,
			((_id & $00FF0000) >> 16) / 255,
			((_id & $FF000000) >> 24) / 255);
	};

	/// @func set_material_index(_index)
	///
	/// @desc Sets the `bbmod_MaterialIndex` uniform.
	///
	/// @param {Real} [_index] The index of the current material.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	static set_material_index = function (_index) {
		gml_pragma("forceinline");
		return set_uniform_f(UMaterialIndex, _index);
	};

	/// @func set_ibl([_ibl])
	///
	/// @desc Sets a fragment shader uniform `bbmod_IBLTexel` and samplers
	/// `bbmod_IBL` and `bbmod_BRDF`. These are required for image based
	/// lighting.
	///
	/// @param {Struct.BBMOD_ImageBasedLight} [_ibl] The image based light.
	/// If `undefined`, then the value set by {@link bbmod_ibl_set} is used. If
	/// the light is not enabled, then it is not passed.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	static set_ibl = function (_ibl=undefined) {
		gml_pragma("forceinline");

		static _iblNull = sprite_get_texture(BBMOD_SprBlack, 0);
		var _texture = _iblNull;
		var _texel = 0.0;

		_ibl ??= global.__bbmodImageBasedLight;
		if (_ibl != undefined && _ibl.Enabled)
		{
			_texture = _ibl.Texture;
			_texel = _ibl.Texel;
		}

		gpu_set_tex_mip_enable_ext(UIBL, mip_off);
		gpu_set_tex_filter_ext(UIBL, true);
		gpu_set_tex_repeat_ext(UIBL, false);
		set_sampler(UIBL, _texture);
		set_uniform_f2(UIBLTexel, _texel, _texel)

		return self;
	};

	/// @func set_ambient_light([_up[, _down]])
	///
	/// @desc Sets the `bbmod_LightAmbientUp`, `bbmod_LightAmbientDown` uniforms.
	///
	/// @param {Struct.BBMOD_Color} [_up] RGBM encoded ambient light color on
	/// the upper hemisphere. If `undefined`, then the value set by
	/// {@link bbmod_light_ambient_set_up} is used.
	/// @param {Struct.BBMOD_Color} [_down] RGBM encoded ambient light color on
	/// the lower hemisphere. If `undefined`, then the value set by
	/// {@link bbmod_light_ambient_set_down} is used.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	static set_ambient_light = function (_up=undefined, _down=undefined) {
		gml_pragma("forceinline");
		_up ??= global.__bbmodAmbientLightUp;
		_down ??= global.__bbmodAmbientLightDown;
		set_uniform_f4(ULightAmbientUp,
			_up.Red / 255.0, _up.Green / 255.0, _up.Blue / 255.0, _up.Alpha);
		set_uniform_f4(ULightAmbientDown,
			_down.Red / 255.0, _down.Green / 255.0, _down.Blue / 255.0, _down.Alpha);
		return self;
	};

	/// @func set_directional_light([_light])
	///
	/// @desc Sets uniforms `bbmod_LightDirectionalDir` and
	/// `bbmod_LightDirectionalColor`.
	///
	/// @param {Struct.BBMOD_DirectionalLight} [_light] The directional light.
	/// If `undefined`, then the value set by {@link bbmod_light_directional_set}
	/// is used. If the light is not enabled then it is not passed.
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	///
	/// @see BBMOD_DirectionalLight
	static set_directional_light = function (_light=undefined) {
		gml_pragma("forceinline");
		_light ??= global.__bbmodDirectionalLight;
		if (_light != undefined	&& _light.Enabled)
		{
			var _direction = _light.Direction;
			set_uniform_f3(ULightDirectionalDir,
				_direction.X, _direction.Y, _direction.Z);
			var _color = _light.Color;
			set_uniform_f4(ULightDirectionalColor,
				_color.Red / 255.0,
				_color.Green / 255.0,
				_color.Blue / 255.0,
				_color.Alpha);
		}
		else
		{
			set_uniform_f3(ULightDirectionalDir, 0.0, 0.0, -1.0);
			set_uniform_f4(ULightDirectionalColor, 0.0, 0.0, 0.0, 0.0);
		}
		return self;
	};

	/// @func set_point_lights([_lights])
	///
	/// @desc Sets uniform `bbmod_LightPointData`.
	///
	/// @param {Array<Struct.BBMOD_PointLight>} [_lights] An array of point
	/// lights. If `undefined`, then the lights defined using
	/// {@link bbmod_light_point_add} are passed. Only enabled lights will be used!
	///
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	static set_point_lights = function (_lights=undefined) {
		gml_pragma("forceinline");
		_lights ??= global.__bbmodPointLights;
		var _maxLights = MaxPointLights;
		var _index = 0;
		var _indexMax = _maxLights * 8;
		var _data = array_create(_indexMax, 0.0);
		var i = 0;
		repeat (array_length(_lights))
		{
			var _light = _lights[i++];
			if (_light.Enabled)
			{
				_light.Position.ToArray(_data, _index);
				_data[@ _index + 3] = _light.Range;
				var _color = _light.Color;
				_data[@ _index + 4] = _color.Red / 255.0;
				_data[@ _index + 5] = _color.Green / 255.0;
				_data[@ _index + 6] = _color.Blue / 255.0;
				_data[@ _index + 7] = _color.Alpha;
				_index += 8;
				if (_index >= _indexMax)
				{
					break;
				}
			}
		}
		set_uniform_f_array(ULightPointData, _data);
		return self;
	};

	/// @func set_fog([_color[, _intensity[, _start[, _end]]]])
	///
	/// @desc Sets uniforms `bbmod_FogColor`, `bbmod_FogIntensity`,
	/// `bbmod_FogStart` and `bbmod_FogRcpRange`.
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
	static set_fog = function (_color=undefined, _intensity=undefined, _start=undefined, _end=undefined) {
		gml_pragma("forceinline");
		_color ??= global.__bbmodFogColor;
		_intensity ??= global.__bbmodFogIntensity;
		_start ??= global.__bbmodFogStart;
		_end ??= global.__bbmodFogEnd;
		var _rcpFogRange = 1.0 / (_end - _start);
		set_uniform_f4(UFogColor,
			_color.Red / 255.0,
			_color.Green / 255.0,
			_color.Blue / 255.0,
			_color.Alpha);
		set_uniform_f(UFogIntensity, _intensity);
		set_uniform_f(UFogStart, _start);
		set_uniform_f(UFogRcpRange, _rcpFogRange);
		return self;
	};

	static on_set = function () {
		gml_pragma("forceinline");
		set_cam_pos();
		set_exposure();
		set_ibl();
		set_ambient_light();
		set_directional_light();
		set_point_lights();
		set_fog();
		set_sampler(USSAO, sprite_get_texture(BBMOD_SprWhite, 0));
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
	static set_material = function (_material) {
		gml_pragma("forceinline");
		set_uniform_f4(
			UBaseOpacityMultiplier,
			_material.BaseOpacityMultiplier.Red / 255.0,
			_material.BaseOpacityMultiplier.Green / 255.0,
			_material.BaseOpacityMultiplier.Blue / 255.0,
			_material.BaseOpacityMultiplier.Alpha);
		set_alpha_test(_material.AlphaTest);
		set_texture_offset(_material.TextureOffset);
		set_texture_scale(_material.TextureScale);
		set_uniform_f(UShadowmapBias, _material.ShadowmapBias);
		return self;
	};
}

////////////////////////////////////////////////////////////////////////////////
//
// Camera
//

/// @var {Struct.BBMOD_Vec3}
/// @private
global.__bbmodCameraPosition = new BBMOD_Vec3();

/// @var {Real} Distance to the far clipping plane.
/// @private
global.__bbmodZFar = 1.0;

/// @var {Real}
/// @private
global.__bbmodCameraExposure = 1.0;

/// @func bbmod_camera_get_position()
///
/// @desc Retrieves the position of the camera that is passed to shaders.
///
/// @return {Struct.BBMOD_Vec3} The camera position.
///
/// @see bbmod_camera_set_position
function bbmod_camera_get_position()
{
	gml_pragma("forceinline");
	return global.__bbmodCameraPosition;
}

/// @func bbmod_camera_set_position(_position)
///
/// @desc Defines position of the camera passed to shaders.
///
/// @param {Struct.BBMOD_Vec3} _position The new camera position.
///
/// @see bbmod_camera_get_position
function bbmod_camera_set_position(_position)
{
	gml_pragma("forceinline");
	global.__bbmodCameraPosition = _position;
}

/// @func bbmod_camera_get_zfar()
///
/// @desc Retrieves distance to the far clipping plane passed to shaders.
///
/// @return {Real} The distance to the far clipping plane.
///
/// @see bbmod_camera_set_zfar
function bbmod_camera_get_zfar()
{
	gml_pragma("forceinline");
	return global.__bbmodZFar;
}

/// @func bbmod_camera_set_zfar(_value)
///
/// @desc Defines distance to the far clipping plane passed to shaders.
///
/// @param {Real} _value The new distance to the far clipping plane.
///
/// @see bbmod_camera_get_zfar
function bbmod_camera_set_zfar(_value)
{
	gml_pragma("forceinline");
	global.__bbmodZFar = _value;
}

/// @func bbmod_camera_get_exposure()
///
/// @desc Retrieves camera exposure value passed to shaders.
///
/// @return {Real} The camera exposure value.
///
/// @see bbmod_camera_set_exposure
function bbmod_camera_get_exposure()
{
	gml_pragma("forceinline");
	return global.__bbmodCameraExposure;
}

/// @func bbmod_camera_set_exposure(_exposure)
///
/// @desc Defines camera exposure value passed to shaders.
///
/// @param {Real} _exposure The new camera exposure value.
///
/// @see bbmod_camera_get_exposure
function bbmod_camera_set_exposure(_exposure)
{
	gml_pragma("forceinline");
	global.__bbmodCameraExposure = _exposure;
}

////////////////////////////////////////////////////////////////////////////////
//
// Ambient light
//

/// @var {Struct.BBMOD_Color}
/// @private
global.__bbmodAmbientLightUp = BBMOD_C_WHITE;

/// @var {Struct.BBMOD_Color}
/// @private
global.__bbmodAmbientLightDown = BBMOD_C_GRAY;

/// @var {Bool}
/// @private
global.__bbmodAmbientAffectLightmap = true;

/// @func bbmod_light_ambient_set(_color)
///
/// @desc Defines color of the ambient light passed to shaders.
///
/// @param {Struct.BBMOD_Color} _color The new color of the ambient light (both
/// upper and lower hemisphere).
///
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_get_down
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
function bbmod_light_ambient_set(_color)
{
	gml_pragma("forceinline");
	global.__bbmodAmbientLightUp = _color;
	global.__bbmodAmbientLightDown = _color;
}

/// @func bbmod_light_ambient_get_up()
///
/// @desc Retrieves color of the upper hemisphere of the ambient light passed
/// to shaders.
///
/// @return {Struct.BBMOD_Color} The color of the upper hemisphere of the
/// ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_get_down
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
function bbmod_light_ambient_get_up()
{
	gml_pragma("forceinline");
	return global.__bbmodAmbientLightUp;
}

/// @func bbmod_light_ambient_set_up(_color)
///
/// @desc Defines color of the upper hemisphere of the ambient light passed to
/// shaders.
///
/// @param {Struct.BBMOD_Color} _color The new color of the upper hemisphere of
/// the ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_get_down
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
function bbmod_light_ambient_set_up(_color)
{
	gml_pragma("forceinline");
	global.__bbmodAmbientLightUp = _color;
}

/// @func bbmod_light_ambient_get_down()
///
/// @desc Retrieves color of the lower hemisphere of the ambient light passed
/// to shaders.
///
/// @return {Struct.BBMOD_Color} The color of the lower hemisphere of the
/// ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
function bbmod_light_ambient_get_down()
{
	gml_pragma("forceinline");
	return global.__bbmodAmbientLightDown;
}

/// @func bbmod_light_ambient_set_down(_color)
///
/// @desc Defines color of the lower hemisphere of the ambient light passed to
/// shaders.
///
/// @param {Struct.BBMOD_Color} _color The new color of the lower hemisphere of
/// the ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_get_down
/// @see BBMOD_Color
function bbmod_light_ambient_set_down(_color)
{
	gml_pragma("forceinline");
	global.__bbmodAmbientLightDown = _color;
}

/// @func bbmod_light_ambient_get_affect_lightmaps()
///
/// @desc Checks whether ambient light affects materials that use baked
/// lightmaps.
///
/// @return {Bool} Returns `true` if ambient light affects materials that
/// use lightmaps.
function bbmod_light_ambient_get_affect_lightmaps()
{
	gml_pragma("forceinline");
	return global.__bbmodAmbientAffectLightmap;
}

/// @func bbmod_light_ambient_set_affect_lightmaps(_enable)
///
/// @desc Configures whether ambient light affects materials that use baked
/// lightmaps.
///
/// @param {Bool} _enable Use `true` to enable ambient light affecting materials
/// that use baked lightmaps.
function bbmod_light_ambient_set_affect_lightmaps(_enable)
{
	gml_pragma("forceinline");
	global.__bbmodAmbientAffectLightmap = _enable;
}

////////////////////////////////////////////////////////////////////////////////
//
// Image based light
//

/// @var {Struct.BBMOD_ImageBasedLight}
/// @private
global.__bbmodImageBasedLight = undefined;

/// @func bbmod_ibl_get()
///
/// @desc Retrieves the image based light passed to shaders.
///
/// @return {Struct.BBMOD_ImageBasedLight} The image based light or `undefined`.
///
/// @see bbmod_ibl_set
/// @see BBMOD_ImageBasedLight
function bbmod_ibl_get()
{
	gml_pragma("forceinline");
	return global.__bbmodImageBasedLight;
}

/// @func bbmod_ibl_set(_ibl)
///
/// @desc Defines the image based light passed to shaders.
///
/// @param {Struct.BBMOD_ImageBasedLight} _ibl The new image based light or
/// `undefined`.
///
/// @see bbmod_ibl_get
/// @see BBMOD_ImageBasedLight
function bbmod_ibl_set(_ibl)
{
	gml_pragma("forceinline");
	global.__bbmodImageBasedLight = _ibl;
}

////////////////////////////////////////////////////////////////////////////////
//
// Directional light
//

/// @var {Struct.BBMOD_DirectionalLight}
/// @private
global.__bbmodDirectionalLight = undefined;

/// @func bbmod_light_directional_get()
///
/// @desc Retrieves the directional light passed to shaders.
///
/// @return {Struct.BBMOD_DirectionalLight} The directional light or `undefined`.
///
/// @see bbmod_light_directional_set
/// @see BBMOD_DirectionalLight
function bbmod_light_directional_get()
{
	gml_pragma("forceinline");
	return global.__bbmodDirectionalLight;
}

/// @func bbmod_light_directional_set(_light)
///
/// @desc Defines the directional light passed to shaders.
///
/// @param {Struct.BBMOD_DirectionalLight} _light The new directional light or
/// `undefined`.
///
/// @see bbmod_light_directional_get
/// @see BBMOD_DirectionalLight
function bbmod_light_directional_set(_light)
{
	gml_pragma("forceinline");
	global.__bbmodDirectionalLight = _light;
}

////////////////////////////////////////////////////////////////////////////////
//
// Point lights
//

/// @var {Array<Struct.BBMOD_PointLight>}
/// @private
global.__bbmodPointLights = [];

/// @func bbmod_light_point_add(_light)
///
/// @desc Adds a point light to be sent to shaders.
///
/// @param {Struct.BBMOD_PointLight} _light The point light.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_count
/// @see bbmod_light_point_get
/// @see bbmod_light_point_remove
/// @see bbmod_light_point_remove_index
/// @see bbmod_light_point_clear
/// @see BBMOD_PointLight
function bbmod_light_point_add(_light)
{
	gml_pragma("forceinline");
	array_push(global.__bbmodPointLights, _light);
}

/// @func bbmod_light_point_count()
///
/// @desc Retrieves number of point lights added to be sent to shaders.
///
/// @return {Real} The number of point lights added to be sent to shaders.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_get
/// @see bbmod_light_point_remove
/// @see bbmod_light_point_remove_index
/// @see bbmod_light_point_clear
/// @see BBMOD_PointLight
function bbmod_light_point_count()
{
	gml_pragma("forceinline");
	return array_length(global.__bbmodPointLights);
}

/// @func bbmod_light_point_get(_index)
///
/// @desc Retrieves a point light at given index.
///
/// @param {Real} _index The index of the point light.
///
/// @return {Struct.BBMOD_PointLight} The point light.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_count
/// @see bbmod_light_point_remove
/// @see bbmod_light_point_remove_index
/// @see bbmod_light_point_clear
/// @see BBMOD_PointLight
function bbmod_light_point_get(_index)
{
	gml_pragma("forceinline");
	return global.__bbmodPointLights[_index];
}

/// @func bbmod_light_point_remove(_light)
///
/// @desc Removes a point light so it is not sent to shaders anymore.
///
/// @param {Struct.BBMOD_PointLight} _light The point light to remove.
///
/// @return {Bool} Returns `true` if the point light was removed or `false` if
/// the light was not found.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_count
/// @see bbmod_light_point_get
/// @see bbmod_light_point_remove_index
/// @see bbmod_light_point_clear
/// @see BBMOD_PointLight
function bbmod_light_point_remove(_light)
{
	gml_pragma("forceinline");
	var _pointLights = global.__bbmodPointLights;
	var i = 0;
	repeat (array_length(_pointLights))
	{
		if (_pointLights[i] == _light)
		{
			array_delete(_pointLights, i, 1);
			return true;
		}
		++i;
	}
	return false;
}

/// @func bbmod_light_point_remove_index(_index)
///
/// @desc Removes a point light so it is not sent to shaders anymore.
///
/// @param {Real} _index The index to remove the point light at.
///
/// @return {Bool} Always returns `true`.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_count
/// @see bbmod_light_point_get
/// @see bbmod_light_point_remove
/// @see bbmod_light_point_clear
/// @see BBMOD_PointLight
function bbmod_light_point_remove_index(_index)
{
	gml_pragma("forceinline");
	array_delete(global.__bbmodPointLights, _index, 1);
	return true;
}

/// @func bbmod_light_point_clear()
///
/// @desc Removes all point lights sent to shaders.
///
/// @see bbmod_light_point_add
/// @see bbmod_light_point_count
/// @see bbmod_light_point_get
/// @see bbmod_light_point_remove
/// @see bbmod_light_point_remove_index
/// @see BBMOD_PointLight
function bbmod_light_point_clear(_index)
{
	gml_pragma("forceinline");
	global.__bbmodPointLights = [];
}

////////////////////////////////////////////////////////////////////////////////
//
// Fog
//

/// @var {Struct.BBMOD_Color}
/// @private
global.__bbmodFogColor = BBMOD_C_WHITE;

/// @var {Real}
/// @private
global.__bbmodFogIntensity = 0.0;

/// @var {Real}
/// @private
global.__bbmodFogStart = 0.0;

/// @var {Real}
/// @private
global.__bbmodFogEnd = 1.0;

/// @func bbmod_fog_set(_color, _intensity, _start, _end)
///
/// @desc Defines fog properties sent to shaders.
///
/// @param {Struct.BBMOD_Color} _color The color of the fog. The default fog
/// color is white.
/// @param {Real} _intensity The intensity of the fog. Use values in range 0..1.
/// The default fog intensity is 0 (no fog).
/// @param {Real} _start The distance from the camera where the fog starts at.
/// The default fog start is 0.
/// @param {Real} _end The distance from the camera where the fog has the
/// maximum intensity. The default fog end is 1.
///
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see BBMOD_Color
function bbmod_fog_set(_color, _intensity, _start, _end)
{
	gml_pragma("forceinline");
	global.__bbmodFogColor = _color;
	global.__bbmodFogIntensity = _intensity;
	global.__bbmodFogStart = _start;
	global.__bbmodFogEnd = _end;
}

/// @func bbmod_fog_get_color()
///
/// @desc Retrieves the color of the fog that is sent to shaders.
///
/// @return {Struct.BBMOD_Color} The color of the fog.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see BBMOD_Color
function bbmod_fog_get_color()
{
	gml_pragma("forceinline");
	return global.__bbmodFogColor;
}

/// @func bbmod_fog_set_color(_color)
///
/// @desc Defines the color of the fog that is sent to shaders.
///
/// @param {Struct.BBMOD_Color} _color The new fog color. The default fog color
/// is white.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see BBMOD_Color
function bbmod_fog_set_color(_color)
{
	gml_pragma("forceinline");
	global.__bbmodFogColor = _color;
}

/// @func bbmod_fog_get_intensity()
///
/// @desc Retrieves the fog intensity that is sent to shaders.
///
/// @return {Real} The fog intensity.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
function bbmod_fog_get_intensity()
{
	gml_pragma("forceinline");
	return global.__bbmodFogIntensity;
}

/// @func bbmod_fog_set_intensity(_intensity)
///
/// @desc Defines the fog intensity that is sent to shaders.
///
/// @param {Real} _intensity The new fog intensity. The default intensity of the
/// fog is 0 (no fog).
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
function bbmod_fog_set_intensity(_intensity)
{
	gml_pragma("forceinline");
	global.__bbmodFogIntensity = _intensity;
}

/// @func bbmod_fog_get_start()
///
/// @desc Retrieves the distance where the fog starts at, as it is defined to be
/// sent to shaders.
///
/// @return {Real} The distance where the fog starts at.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
function bbmod_fog_get_start()
{
	gml_pragma("forceinline");
	return global.__bbmodFogStart;
}

/// @func bbmod_fog_set_start(_start)
///
/// @desc Defines distance where the fog starts at - to be sent to shaders.
///
/// @param {Real} _start The new distance where the fog starts at. The default
/// value is 0.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
function bbmod_fog_set_start(_start)
{
	gml_pragma("forceinline");
	global.__bbmodFogStart = _start;
}

/// @func bbmod_fog_get_end()
///
/// @desc Retrieves the distance where the fog has the maximum intensity, as it
/// is defined to be sent to shaders.
///
/// @return {Real} The distance where the fog has the maximum intensity.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_set_end
function bbmod_fog_get_end()
{
	gml_pragma("forceinline");
	return global.__bbmodFogEnd;
}

/// @func bbmod_fog_set_end(_end)
///
/// @desc Defines the distance where the fog has the maximum intensity - to be
/// sent to shaders.
///
/// @param {Real} _end The distance where the fog has the maximum intensity.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
function bbmod_fog_set_end(_end)
{
	gml_pragma("forceinline");
	global.__bbmodFogEnd = _end;
}
