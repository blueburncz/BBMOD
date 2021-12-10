/// @func BBMOD_Shader(_shader, _vertexFormat)
/// @extends BBMOD_BaseShader
/// @desc Base class for shaders used by BBMOD materials.
/// @param {shader} _shader The shader resource.
/// @param {BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
/// @see BBMOD_Material
function BBMOD_Shader(_shader, _vertexFormat)
	: BBMOD_BaseShader(_shader, _vertexFormat) constructor
{
	/// @var {uint} Maximum number of point lights in the shader. This must match
	/// with value defined in the raw GameMaker shader!
	MaxPointLights = 8;

	UTextureOffset = get_uniform("bbmod_TextureOffset");

	UTextureScale = get_uniform("bbmod_TextureScale");

	UBones = get_uniform("bbmod_Bones");

	UBatchData = get_uniform("bbmod_BatchData");

	UAlphaTest = get_uniform("bbmod_AlphaTest");

	UCamPos = get_uniform("bbmod_CamPos");

	UExposure = get_uniform("bbmod_Exposure");

	ULightAmbientUp = get_uniform("bbmod_LightAmbientUp");

	ULightAmbientDown = get_uniform("bbmod_LightAmbientDown");

	ULightDirectionalDir = get_uniform("bbmod_LightDirectionalDir");

	ULightDirectionalColor = get_uniform("bbmod_LightDirectionalColor");

	ULightPointData = get_uniform("bbmod_LightPointData");

	UFogColor = get_uniform("bbmod_FogColor");

	UFogIntensity = get_uniform("bbmod_FogIntensity");

	UFogStart = get_uniform("bbmod_FogStart");

	UFogRcpRange = get_uniform("bbmod_FogRcpRange");

	/// @func set_texture_offset(_offset)
	/// @desc Sets the `bbmod_TextureOffset` uniform to the given offset.
	/// @param {BBMOD_Vec2} _offset The texture offset.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_texture_offset = function (_offset) {
		gml_pragma("forceinline");
		return set_uniform_f2(UTextureOffset, _offset.X, _offset.Y);
	};

	/// @func set_texture_scale(_scale)
	/// @desc Sets the `bbmod_TextureScale` uniform to the given scale.
	/// @param {BBMOD_Vec2} _scale The texture scale.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_texture_scale = function (_scale) {
		gml_pragma("forceinline");
		return set_uniform_f2(UTextureScale, _scale.X, _scale.Y);
	};

	/// @func set_bones(_bones)
	/// @desc Sets the `bbmod_Bones` uniform.
	/// @param {real[]} _bones The array of bone transforms.
	/// @return {BBMOD_Shader} Returns `self`.
	/// @see BBMOD_AnimationPlayer.get_transform
	static set_bones = function (_bones) {
		gml_pragma("forceinline");
		return set_uniform_f_array(UBones, _bones);
	};

	/// @func set_batch_data(_data)
	/// @desc Sets the `bbmod_BatchData` uniform.
	/// @param {real[]} _data The dynamic batch data.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_batch_data = function (_data) {
		gml_pragma("forceinline");
		return set_uniform_f_array(UBatchData, _data);
	};

	/// @func set_alpha_test(_value)
	/// @desc Sets the `bbmod_AlphaTest` uniform.
	/// @param {real} _value The alpha test value.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_alpha_test = function (_value) {
		gml_pragma("forceinline");
		return set_uniform_f(UAlphaTest, _value);
	};

	/// @func set_cam_pos([_pos])
	/// @desc Sets a fragment shader uniform `bbmod_CamPos` to the given position.
	/// @param {BBMOD_Vec3} [_pos[ The camera position. Defaults to the value
	/// defined using {@link bbmod_camera_set_position}.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_cam_pos = function (_pos=undefined) {
		gml_pragma("forceinline");
		_pos ??= global.bbmod_camera_position;
		return set_uniform_f3(UCamPos, _pos.X, _pos.Y, _pos.Z);
	};

	/// @func set_exposure([_value])
	/// @desc Sets the `bbmod_Exposure` uniform.
	/// @param {real} [_value] The camera exposure. Defaults to the value
	/// defined using {@link bbmod_camera_set_exposure}.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_exposure = function (_value=undefined) {
		gml_pragma("forceinline");
		_value ??= global.bbmod_camera_exposure;
		return set_uniform_f(UExposure, _value);
	};

	/// @func set_ambient_light([_up[, _down]])
	/// @desc Sets the `bbmod_AmbientUp`, `bbmod_AmbientDown` uniforms.
	/// @param {BBMOD_Color} [_up] RGBM encoded ambient light color on
	/// the upper hemisphere. Defaults to the color defined using
	/// {@link bbmod_light_ambient_up_set}.
	/// @param {BBMOD_Color} [_down] RGBM encoded ambient light color on
	/// the lower hemisphere. Defaults to the color defined using
	/// {@link bbmod_light_ambient_down_set}.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_ambient_light = function (_up=undefined, _down=undefined) {
		gml_pragma("forceinline");
		_up ??= global.__bbmodAmbientLightUp;
		_down ??= global.__bbmodAmbientLightDown;
		set_uniform_f_array(ULightAmbientUp, _up.ToRGBM());
		set_uniform_f_array(ULightAmbientDown, _down.ToRGBM());
		return self;
	};

	/// @func set_directional_light([_light])
	/// @desc Sets uniforms `bbmod_LightDirectionalDir` and
	/// `bbmod_LightDirectionalColor`.
	/// @param {BBMOD_DirectionalLight} [_light] The directional light. Defaults
	/// to the light set using {@link bbmod_light_directional_set}.
	/// @return {BBMOD_PBRShader} Returns `self`.
	/// @see BBMOD_DirectionalLight
	static set_directional_light = function (_light=undefined) {
		gml_pragma("forceinline");
		_light ??= global.__bbmodDirectionalLight;
		if (_light != undefined)
		{
			var _direction = _light.Direction;
			set_uniform_f3(ULightDirectionalDir, _direction.X, _direction.Y, _direction.Z);
			set_uniform_f_array(ULightDirectionalColor, _light.Color.ToRGBM());
		}
		else
		{
			set_uniform_f3(ULightDirectionalDir, 0.0, 0.0, -1.0);
			set_uniform_f4(ULightDirectionalColor, 0.0, 0.0, 0.0, 0.0);
		}
		return self;
	};

	/// @func set_point_lights([_lights])
	/// @desc Sets uniform `bbmod_LightPointData`.
	/// @param {BBMOD_PointLight[]} [_lights] An array of point lights. Defaults
	/// to the lights defined using {@link bbmod_light_point_add}.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_point_lights = function (_lights=undefined) {
		gml_pragma("forceinline");
		_lights ??= global.__bbmodPointLights;
		var _maxLights = MaxPointLights;
		var _data = array_create(_maxLights * 8, 0.0);
		var _imax = min(array_length(_lights), _maxLights);
		for (var i = 0; i < _imax; ++i)
		{
			var _index = i * 8;
			var _light = _lights[i];
			_light.Position.ToArray(_data, _index);
			_data[@ _index + 3] = _light.Range;
			_light.Color.ToRGBM(_data, _index + 4);
		}
		set_uniform_f_array(ULightPointData, _data);
		return self;
	};

	/// @func set_fog([_color[, _intensity[, _start[, _end]]]])
	/// @desc
	/// @param {BBMOD_Color} [_color]
	/// @param {real} [_intensity]
	/// @param {real} [_start]
	/// @param {real} [_end]
	/// @return {BBMOD_Shader] Returns `self`.
	static set_fog = function (_color=undefined, _intensity=undefined, _start=undefined, _end=undefined) {
		gml_pragma("forceinline");
		_color ??= global.__bbmodFogColor;
		_intensity ??= global.__bbmodFogIntensity;
		_start ??= global.__bbmodFogStart;
		_end ??= global.__bbmodFogEnd;
		var _rcpFogRange = 1.0 / (_end - _start);
		set_uniform_f_array(UFogColor, _color.ToRGBM());
		set_uniform_f(UFogIntensity, _intensity);
		set_uniform_f(UFogStart, _start);
		set_uniform_f(UFogRcpRange, _rcpFogRange);
		return self;
	};

	static on_set = function () {
		gml_pragma("forceinline");
		set_cam_pos();
		set_exposure();
		set_ambient_light();
		set_directional_light();
		set_point_lights();
		set_fog();
	};

	/// @func set_material(_material)
	/// @desc Sets shader uniforms using values from the material.
	/// @param {BBMOD_Material} _material The material to take the values from.
	/// @return {BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Material
	static set_material = function (_material) {
		gml_pragma("forceinline");
		set_alpha_test(_material.AlphaTest);
		set_texture_offset(_material.TextureOffset);
		set_texture_scale(_material.TextureScale);
		return self;
	};
}

////////////////////////////////////////////////////////////////////////////////
//
// Camera
//

/// @var {real[]} The current `[x,y,z]` position of the camera. This should be
/// updated every frame before rendering models.
/// @deprecated Please use {@link bbmod_camera_get_position} and
/// {@link bbmod_camera_set_position} instead.
global.bbmod_camera_position = new BBMOD_Vec3();

/// @var {real} The current camera exposure.
/// @deprecated Please use {@link bbmod_camera_get_exposure} and
/// {@link bbmod_camera_set_exposure} instead.
global.bbmod_camera_exposure = 1.0;

/// @func bbmod_set_camera_position(_x, _y, _z)
/// @desc Changes camera position to given coordinates.
/// @param {real} _x The x position of the camera.
/// @param {real} _y The y position of the camera.
/// @param {real} _z The z position of the camera.
/// @deprecated Please use {@link bbmod_camera_set_position} instead.
function bbmod_set_camera_position(_x, _y, _z)
{
	gml_pragma("forceinline");
	var _position = global.bbmod_camera_position;
	_position.X = _x;
	_position.Y = _y;
	_position.Z = _z;
}

/// @func bbmod_camera_get_position()
/// @desc
/// @return {BBMOD_Vec3}
function bbmod_camera_get_position()
{
	gml_pragma("forceinline");
	return global.bbmod_camera_position;
}

/// @func bbmod_camera_set_position(_position)
/// @desc
/// @param {BBMOD_Vec3} _position
function bbmod_camera_set_position(_position)
{
	gml_pragma("forceinline");
	global.bbmod_camera_position = _position;
}

/// @func bbmod_camera_get_exposure()
/// @desc
/// @return {real}
function bbmod_camera_get_exposure()
{
	gml_pragma("forceinline");
	return global.bbmod_camera_exposure;
}

/// @func bbmod_camera_set_exposure(_exposure)
/// @desc
/// @param {real} _exposure
function bbmod_camera_set_exposure(_exposure)
{
	gml_pragma("forceinline");
	global.bbmod_camera_exposure = _exposure;
}

////////////////////////////////////////////////////////////////////////////////
//
// Ambient light
//

/// @var {BBMOD_Color}
/// @private
global.__bbmodAmbientLightUp = new BBMOD_Color();

/// @var {BBMOD_Color}
/// @private
global.__bbmodAmbientLightDown = new BBMOD_Color().FromConstant(c_gray);

/// @func bbmod_light_ambient_set(_color)
/// @desc
/// @param {BBMOD_Color} _color
function bbmod_light_ambient_set(_color)
{
	gml_pragma("forceinline");
	global.__bbmodAmbientLightUp = _color;
	global.__bbmodAmbientLightDown = _color;
}

/// @func bbmod_light_ambient_up_get()
/// @desc 
/// @return {BBMOD_Color}
function bbmod_light_ambient_up_get()
{
	gml_pragma("forceinline");
	return global.__bbmodAmbientLightUp;
}

/// @func bbmod_light_ambient_up_set(_color)
/// @desc
/// @param {BBMOD_Color} _color
function bbmod_light_ambient_up_set(_color)
{
	gml_pragma("forceinline");
	global.__bbmodAmbientLightUp = _color;
}

/// @func bbmod_light_ambient_down_get()
/// @desc
/// @return {BBMOD_Color}
function bbmod_light_ambient_down_get()
{
	gml_pragma("forceinline");
	return global.__bbmodAmbientLightDown;
}

/// @func bbmod_light_ambient_down_set(_color)
/// @desc
/// @param {BBMOD_Color} _color
function bbmod_light_ambient_down_set(_color)
{
	gml_pragma("forceinline");
	global.__bbmodAmbientLightDown = _color;
}

////////////////////////////////////////////////////////////////////////////////
//
// Image based light
//

/// @var {BBMOD_ImageBasedLight/undefined}
/// @private
global.__bbmodImageBasedLight = undefined;

/// @func bbmod_ibl_get()
/// @desc
/// @return {BBMOD_ImageBasedLight}
function bbmod_ibl_get()
{
	gml_pragma("forceinline");
	return global.__bbmodImageBasedLight;
}

/// @func bbmod_ibl_set(_ibl)
/// @desc
/// @param {BBMOD_ImageBasedLight} _ibl
function bbmod_ibl_set(_ibl)
{
	gml_pragma("forceinline");
	global.__bbmodImageBasedLight = _ibl;
}

////////////////////////////////////////////////////////////////////////////////
//
// Directional light
//

/// @var {BBMOD_DirectionalLight/undefined}
/// @private
global.__bbmodDirectionalLight = undefined;

/// @func bbmod_light_directional_get()
/// @desc
/// @return {BBMOD_DirectionalLight/undefined}
function bbmod_light_directional_get()
{
	gml_pragma("forceinline");
	return global.__bbmodDirectionalLight;
}

/// @func bbmod_light_directional_set(_light)
/// @desc
/// @param {BBMOD_DirectionalLight/undefined} _light
function bbmod_light_directional_set(_light)
{
	gml_pragma("forceinline");
	global.__bbmodDirectionalLight = _light;
}

////////////////////////////////////////////////////////////////////////////////
//
// Point lights
//

/// @var {BBMOD_PointLight[]}
/// @private
global.__bbmodPointLights = [];

/// @func bbmod_light_point_add(_light)
/// @desc
/// @param {BBMOD_PointLight} _light
function bbmod_light_point_add(_light)
{
	gml_pragma("forceinline");
	array_push(global.__bbmodPointLights, _light);
}

/// @func bbmod_light_point_count()
/// @desc
/// @return {uint}
function bbmod_light_point_count()
{
	gml_pragma("forceinline");
	return array_length(global.__bbmodPointLights);
}

/// @func bbmod_light_point_get(_index)
/// @desc
/// @param {uint} _index
/// @return {BBMOD_PointLight}
function bbmod_light_point_get(_index)
{
	gml_pragma("forceinline");
	return global.__bbmodPointLights[_index];
}

/// @func bbmod_light_point_remove(_light)
/// @desc
/// @param {BBMOD_PointLight} _light
/// @return {bool}
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
/// @desc
/// @param {uint} _index
/// @return {bool}
function bbmod_light_point_remove_index(_index)
{
	gml_pragma("forceinline");
	array_delete(global.__bbmodPointLights, _index, 1);
	return true;
}

////////////////////////////////////////////////////////////////////////////////
//
// Fog
//

/// @var {BBMOD_Color}
/// @private
global.__bbmodFogColor = new BBMOD_Color();

/// @var {real}
/// @private
global.__bbmodFogIntensity = 0.0;

/// @var {real}
/// @private
global.__bbmodFogStart = 0.0;

/// @var {real}
/// @private
global.__bbmodFogEnd = 1.0;

/// @func bbmod_fog_set(_color, _intensity, _start, _end)
/// @desc
/// @param {BBMOD_Color} _color The color of the fog. The default fog color is
/// white.
/// @param {real} _intensity The intensity of the fog. Use values in range 0..1.
/// The default fog intensity is 0 (no fog).
/// @param {real} _start The distance from the camera where the fog starts at.
/// The default fog start is 0.
/// @param {real} _end The distance from the camera where the fog has the maximum
/// intensity. The default fog end is 1.
function bbmod_fog_set(_color, _intensity, _start, _end)
{
	gml_pragma("forceinline");
	global.__bbmodFogColor = _color;
	global.__bbmodFogIntensity = _intensity;
	global.__bbmodFogStart = _start;
	global.__bbmodFogEnd = _end;
}

/// @func bbmod_fog_get_color()
/// @desc
/// @return {BBMOD_Color}
function bbmod_fog_get_color()
{
	gml_pragma("forceinline");
	return global.__bbmodFogColor;
}

/// @func bbmod_fog_set_color(_color)
/// @desc
/// @param {BBMOD_Color} _color The color of the fog. The default fog color is
/// white.
function bbmod_fog_set_color(_color)
{
	gml_pragma("forceinline");
	global.__bbmodFogColor = _color;
}

/// @func bbmod_fog_get_intensity()
/// @desc
/// @return {real}
function bbmod_fog_get_intensity()
{
	gml_pragma("forceinline");
	return global.__bbmodFogIntensity;
}

/// @func bbmod_fog_set_intensity(_intensity)
/// @desc
/// @param {real} _intensity
function bbmod_fog_set_intensity(_intensity)
{
	gml_pragma("forceinline");
	global.__bbmodFogIntensity = _intensity;
}


/// @func bbmod_fog_get_start()
/// @desc
/// @return {real}
function bbmod_fog_get_start()
{
	gml_pragma("forceinline");
	return global.__bbmodFogStart;
}

/// @func bbmod_fog_set_start(_start)
/// @desc
/// @param {real} _start
function bbmod_fog_set_start(_start)
{
	gml_pragma("forceinline");
	global.__bbmodFogStart = _start;
}

/// @func bbmod_fog_get_end()
/// @desc
/// @return {real}
function bbmod_fog_get_end()
{
	gml_pragma("forceinline");
	return global.__bbmodFogEnd;
}

/// @func bbmod_fog_set_end(_end)
/// @desc
/// @param {real} _end
function bbmod_fog_set_end(_end)
{
	gml_pragma("forceinline");
	global.__bbmodFogEnd = _end;
}