/// @func BBMOD_DefaultShader(_shader, _vertexFormat)
/// @extends BBMOD_BaseShader
/// @desc Shader used by the default BBMOD materials.
/// @param {shader} _shader The shader resource.
/// @param {BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
/// @see BBMOD_DefaultMaterial
function BBMOD_DefaultShader(_shader, _vertexFormat)
	: BBMOD_BaseShader(_shader, _vertexFormat) constructor
{
	static Super_BaseShader = {
		on_set: on_set,
		set_material: set_material,
	};

	/// @var {uint} Maximum number of point lights in the shader. This must match
	/// with value defined in the raw GameMaker shader!
	MaxPointLights = 8;

	UNormalSmoothness = get_sampler_index("bbmod_NormalSmoothness");

	USpecularColor = get_sampler_index("bbmod_SpecularColor");

	ULightAmbientUp = get_uniform("bbmod_LightAmbientUp");

	ULightAmbientDown = get_uniform("bbmod_LightAmbientDown");

	ULightDirectionalDir = get_uniform("bbmod_LightDirectionalDir");

	ULightDirectionalColor = get_uniform("bbmod_LightDirectionalColor");

	ULightPointData = get_uniform("bbmod_LightPointData");

	UFogColor = get_uniform("bbmod_FogColor");

	UFogIntensity = get_uniform("bbmod_FogIntensity");

	UFogStart = get_uniform("bbmod_FogStart");

	UFogRcpRange = get_uniform("bbmod_FogRcpRange");

	UShadowmapEnable = get_uniform("bbmod_ShadowmapEnable");

	UShadowmap = get_sampler_index("bbmod_Shadowmap");

	UShadowmapMatrix = get_uniform("bbmod_ShadowmapMatrix");

	UShadowmapTexel = get_uniform("bbmod_ShadowmapTexel");

	UShadowmapArea = get_uniform("bbmod_ShadowmapArea");

	UShadowmapNormalOffset = get_uniform("bbmod_ShadowmapNormalOffset");

	/// @func set_normal_smoothness(_texture)
	/// @desc Sets the `bbmod_NormalSmoothness` uniform.
	/// @param {real} _texture The new texture with normal vector in the RGB
	/// channels and smoothness in the A channel.
	/// @return {BBMOD_DefaultShader} Returns `self`.
	static set_normal_smoothness = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(UNormalSmoothness, _texture);
	};

	/// @func set_specular_color(_texture)
	/// @desc Sets the `bbmod_SpecularColor` uniform.
	/// @param {real} _texture The new texture with specular color in the RGB
	/// channels.
	/// @return {BBMOD_DefaultShader} Returns `self`.
	static set_specular_color = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(USpecularColor, _texture);
	};

	/// @func set_ambient_light([_up[, _down]])
	/// @desc Sets the `bbmod_LightAmbientUp`, `bbmod_LightAmbientDown` uniforms.
	/// @param {BBMOD_Color} [_up] RGBM encoded ambient light color on
	/// the upper hemisphere. Defaults to the color defined using
	/// {@link bbmod_light_ambient_set_up}.
	/// @param {BBMOD_Color} [_down] RGBM encoded ambient light color on
	/// the lower hemisphere. Defaults to the color defined using
	/// {@link bbmod_light_ambient_set_down}.
	/// @return {BBMOD_DefaultShader} Returns `self`.
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
	/// to the light set using {@link bbmod_light_directional_set}. If the light
	/// is not enabled then it is not passed.
	/// @return {BBMOD_DefaultShader} Returns `self`.
	/// @see BBMOD_DirectionalLight
	static set_directional_light = function (_light=undefined) {
		gml_pragma("forceinline");
		_light ??= global.__bbmodDirectionalLight;
		if (_light != undefined	&& _light.Enabled)
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
	/// to the lights defined using {@link bbmod_light_point_add}. Only enabled
	/// lights will be used.
	/// @return {BBMOD_DefaultShader} Returns `self`.
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
				_light.Color.ToRGBM(_data, _index + 4);
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
	/// @desc Sets uniforms `bbmod_FogColor`, `bbmod_FogIntensity`,
	/// `bbmod_FogStart` and `bbmod_FogRcpRange`.
	/// @param {BBMOD_Color} [_color] The color of the fog. Defaults to the
	/// color defined using {@link bbmod_fog_set_color}.
	/// @param {real} [_intensity] The fog intensity. Defaults to the value
	/// defined using {@link bbmod_fog_set_intensity}.
	/// @param {real} [_start] The distance at which the fog starts. Defaults
	/// to the value defined using {@link bbmod_fog_set_start}.
	/// @param {real} [_end] The distance at which the fog has maximum intensity.
	/// Defaults to the value defined using {@link bbmod_fog_set_end}.
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

	/// @func set_shadowmap(_texture, _matrix, _area, _normalOffset)
	/// @desc Sets uniforms `bbmod_Shadowmap`, `bbmod_ShadowmapMatrix`,
	/// `bbmod_ShadowmapArea` and `bbmod_ShadowmapNormalOffset`, required for
	/// shadow mapping.
	/// @param {ptr} _texture The shadowmap texture.
	/// @param {real[16]} _matrix The world-view-projection matrix used when
	/// rendering the shadowmap.
	/// @param {real} _area The area that the shadowmap captures.
	/// @param {real} _normalOffset The area that the shadowmap captures.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_shadowmap = function (_texture, _matrix, _area, _normalOffset) {
		gml_pragma("forceinline");
		set_uniform_f(UShadowmapEnable, 1.0);
		set_sampler(UShadowmap, _texture);
		gpu_set_tex_mip_enable_ext(UShadowmap, false);
		gpu_set_tex_filter_ext(UShadowmap, true);
		gpu_set_tex_repeat_ext(UShadowmap, false);
		set_uniform_f2(UShadowmapTexel,
			texture_get_texel_width(_texture),
			texture_get_texel_height(_texture));
		set_uniform_f(UShadowmapArea, _area);
		set_uniform_f(UShadowmapNormalOffset, _normalOffset);
		set_uniform_matrix_array(UShadowmapMatrix, _matrix);
		return self;
	};

	static on_set = function () {
		gml_pragma("forceinline");
		method(self, Super_BaseShader.on_set)();
		set_ambient_light();
		set_directional_light();
		set_point_lights();
		set_fog();
		set_uniform_f(UShadowmapEnable, 0.0);
	};

	static set_material = function (_material) {
		gml_pragma("forceinline");
		method(self, Super_BaseShader.set_material)(_material);
		set_normal_smoothness(_material.NormalSmoothness);
		set_specular_color(_material.SpecularColor);
		return self;
	};
}

////////////////////////////////////////////////////////////////////////////////
//
// Ambient light
//

/// @var {BBMOD_Color}
/// @private
global.__bbmodAmbientLightUp = BBMOD_C_WHITE;

/// @var {BBMOD_Color}
/// @private
global.__bbmodAmbientLightDown = BBMOD_C_GRAY;

/// @func bbmod_light_ambient_set(_color)
/// @desc Defines color of the ambient light passed to shaders.
/// @param {BBMOD_Color} _color The new color of the ambient light (both upper
/// and lower hemisphere).
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
/// @desc Retrieves color of the upper hemisphere of the ambient light passed
/// to shaders.
/// @return {BBMOD_Color} The color of the upper hemisphere of the ambient light.
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
/// @desc Defines color of the upper hemisphere of the ambient light passed to
/// shaders.
/// @param {BBMOD_Color} _color The new color of the upper hemisphere of the
/// ambient light.
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
/// @desc Retrieves color of the lower hemisphere of the ambient light passed
/// to shaders.
/// @return {BBMOD_Color} The color of the lower hemisphere of the ambient light.
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
/// @desc Defines color of the lower hemisphere of the ambient light passed to
/// shaders.
/// @param {BBMOD_Color} _color The new color of the lower hemisphere of the
/// ambient light.
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

////////////////////////////////////////////////////////////////////////////////
//
// Image based light
//

/// @var {BBMOD_ImageBasedLight/undefined}
/// @private
global.__bbmodImageBasedLight = undefined;

/// @func bbmod_ibl_get()
/// @desc Retrieves the image based light passed to shaders.
/// @return {BBMOD_ImageBasedLight/undefined} The image based light.
/// @see bbmod_ibl_set
/// @see BBMOD_ImageBasedLight
function bbmod_ibl_get()
{
	gml_pragma("forceinline");
	return global.__bbmodImageBasedLight;
}

/// @func bbmod_ibl_set(_ibl)
/// @desc Defines the image based light passed to shaders.
/// @param {BBMOD_ImageBasedLight/undefined} _ibl The new image based light.
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

/// @var {BBMOD_DirectionalLight/undefined}
/// @private
global.__bbmodDirectionalLight = undefined;

/// @func bbmod_light_directional_get()
/// @desc Retrieves the directional light passed to shaders.
/// @return {BBMOD_DirectionalLight/undefined} The directional light.
/// @see bbmod_light_directional_set
/// @see BBMOD_DirectionalLight
function bbmod_light_directional_get()
{
	gml_pragma("forceinline");
	return global.__bbmodDirectionalLight;
}

/// @func bbmod_light_directional_set(_light)
/// @desc Defines the directional light passed to shaders.
/// @param {BBMOD_DirectionalLight/undefined} _light The new directional light.
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

/// @var {BBMOD_PointLight[]}
/// @private
global.__bbmodPointLights = [];

/// @func bbmod_light_point_add(_light)
/// @desc Adds a point light to be sent to shaders.
/// @param {BBMOD_PointLight} _light The point light.
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
/// @desc Retrieves number of point lights added to be sent to shaders.
/// @return {uint} The number of point lights added to be sent to shaders.
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
/// @desc Retrieves a point light at given index.
/// @param {uint} _index The index of the point light.
/// @return {BBMOD_PointLight} The point light.
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
/// @desc Removes a point light so it is not sent to shaders anymore.
/// @param {BBMOD_PointLight} _light The point light to remove.
/// @return {bool} Returns `true` if the point light was removed or `false` if
/// the light was not found.
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
/// @desc Removes a point light so it is not sent to shaders anymore.
/// @param {uint} _index The index to remove the point light at.
/// @return {bool} Always returns `true`.
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
/// @desc Removes all point lights sent to shaders.
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

/// @var {BBMOD_Color}
/// @private
global.__bbmodFogColor = BBMOD_C_WHITE;

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
/// @desc Defines fog properties sent to shaders.
/// @param {BBMOD_Color} _color The color of the fog. The default fog color is
/// white.
/// @param {real} _intensity The intensity of the fog. Use values in range 0..1.
/// The default fog intensity is 0 (no fog).
/// @param {real} _start The distance from the camera where the fog starts at.
/// The default fog start is 0.
/// @param {real} _end The distance from the camera where the fog has the maximum
/// intensity. The default fog end is 1.
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
/// @desc Retrieves the color of the fog that is sent to shaders.
/// @return {BBMOD_Color} The color of the fog.
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
/// @desc Defines the color of the fog that is sent to shaders.
/// @param {BBMOD_Color} _color The new fog color. The default fog color is
/// white.
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
/// @desc Retrieves the fog intensity that is sent to shaders.
/// @return {real} The fog intensity.
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
/// @desc Defines the fog intensity that is sent to shaders.
/// @param {real} _intensity The new fog intensity. The default intensity of the
/// fog is 0 (no fog).
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
/// @desc Retrieves the distance where the fog starts at, as it is defined to be
/// sent to shaders.
/// @return {real} The distance where the fog starts at.
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
/// @desc Defines distance where the fog starts at - to be sent to shaders.
/// @param {real} _start The new distance where the fog starts at. The default
/// value is 0.
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
/// @desc Retrieves the distance where the fog has the maximum intensity, as it
/// is defined to be sent to shaders.
/// @return {real} The distance where the fog has the maximum intensity.
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
/// @desc Defines the distance where the fog has the maximum intensity - to be
/// sent to shaders.
/// @param {real} _end The distance where the fog has the maximum intensity.
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