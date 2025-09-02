/// @module Core

/// @var {Struct.BBMOD_Environment} The current environment.
/// @private
global.__bbmodEnvCurrent = undefined;

/// @func BBMOD_Environment()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Stores environment settings like lights, reflection probes and fog.
function BBMOD_Environment() constructor
{
	/// @var {Struct.BBMOD_Vec3} The direction towards the upper hemisphere of
	/// the ambient light. Defaults to {@link BBMOD_VEC3_UP}.
	AmbientLightDirection = BBMOD_VEC3_UP;

	/// @var {Struct.BBMOD_Color} The color of the upper hemisphere of the
	/// ambient light. Defaults to {@link BBMOD_C_WHITE}.
	AmbientLightColorUp = BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Color} The color of the lower hemisphere of the
	/// ambient light. Defaults to {@link BBMOD_C_GRAY}.
	AmbientLightColorDown = BBMOD_C_GRAY;

	/// @var {Bool} Whether ambient light affects lightmapped models. Defaults
	/// to `true`.
	AmbientLightAffectLightmaps = true;

	/// @var {Pointer.Texture} A lightmap applied to the whole environment.
	/// @readonly
	Lightmap = sprite_get_texture(BBMOD_SprBlack, 0);

	/// @var {Struct.BBMOD_DirectionalLight, Undefined} A directional light
	/// applied to the whole environment. Defaults to `undefined`.
	LightDirectional = undefined;

	/// @var {Array<Struct.BBMOD_PunctualLight>} An array of punctual lights
	/// added to the environment.
	/// @readonly
	LightsPunctual = [];

	/// @var {Struct.BBMOD_ImageBasedLight, Undefined} The image-based light
	/// applied to the whole environment. Defaults to `undefined`.
	/// @readonly
	ImageBasedLight = undefined;

	/// @var {Array<Struct.BBMOD_ReflectionProbe>} An array of reflection probes
	/// added to the environment.
	/// @readonly
	ReflectionProbes = [];

	/// @var {Struct.BBMOD_Color} The color of the fog. Defaults to
	/// {@link BBMOD_C_WHITE}.
	FogColor = BBMOD_C_WHITE;

	/// @var {Real} The maximum intensity the fog. Use 0 (default) to disable
	/// fog.
	FogIntensity = 0.0;

	/// @var {Real} The distance from the camera at which the fog starts.
	/// @see BBMOD_Environment.FogEnd
	FogStart = 0.0;

	/// @var {Real} The distance from the camera at which the fog reaches its
	/// maximum intensity.
	/// @see BBMOD_Environment.FogStart
	/// @see BBMOD_Environment.FogIntensity
	FogEnd = 1.0;

	/// @func add_punctual_light(_light)
	///
	/// @desc Adds a punctual light to the environment.
	///
	/// @param {Struct.BBMOD_PunctualLight} _light The light to add.
	///
	/// @return {Struct.BBMOD_Environment} Returns `self`.
	static add_punctual_light = function (_light)
	{
		gml_pragma("forceinline");
		array_push(LightsPunctual, _light);
		return self;
	};

	/// @func get_punctual_light_count()
	///
	/// @desc Retrieves number of punctual lights added to the environment.
	///
	/// @return {Real} The number of punctual lights added to the environment.
	static get_punctual_light_count = function ()
	{
		gml_pragma("forceinline");
		return array_length(LightsPunctual);
	};

	/// @func get_punctual_light(_index)
	///
	/// @desc Retrieves the punctual light at given index.
	///
	/// @param {Real} _index The index of the punctual light.
	///
	/// @return {Struct.BBMOD_PunctualLight} The punctual light at given idnex.
	static get_punctual_light = function (_index)
	{
		gml_pragma("forceinline");
		return LightsPunctual[_index];
	};

	/// @func remove_punctual_light(_light)
	///
	/// @desc Removes a punctual light from the environment.
	///
	/// @param {Struct.BBMOD_PunctualLight} _light The light to remove.
	///
	/// @return {Bool} Returns `true` if the light was removed or `false` if the
	/// light was not found in the environment.
	static remove_punctual_light = function (_light)
	{
		var _punctualLights = LightsPunctual;
		var i = 0;
		repeat(array_length(_punctualLights))
		{
			if (_punctualLights[i] == _light)
			{
				array_delete(_punctualLights, i, 1);
				return true;
			}
			++i;
		}
		return false;
	};

	/// @func remove_punctual_light_index(_index)
	///
	/// @desc Removes a punctual light at given index from the environment.
	///
	/// @param {Real} _index The index to remove the light at.
	///
	/// @return {Struct.BBMOD_Environment} Returns `self`.
	static remove_punctual_light_index = function (_index)
	{
		gml_pragma("forceinline");
		array_delete(LightsPunctual, _index, 1);
		return self;
	};

	/// @func clear_punctual_lights(_index)
	///
	/// @desc Removes all punctual lights added to the environment.
	///
	/// @return {Struct.BBMOD_Environment} Returns `self`.
	static clear_punctual_lights = function ()
	{
		gml_pragma("forceinline");
		LightsPunctual = [];
		return self;
	};

	/// @func add_reflection_probe(_reflectionProbe)
	///
	/// @desc Adds a reflection probe to the environment.
	///
	/// @param {Struct.BBMOD_ReflectionProbe} _reflectionProbe The reflection
	/// probe to add.
	///
	/// @return {Struct.BBMOD_Environment} Returns `self`.
	static add_reflection_probe = function (_reflectionProbe)
	{
		gml_pragma("forceinline");
		array_push(ReflectionProbes, _reflectionProbe);
		return self;
	};

	/// @func get_reflection_probe_count()
	///
	/// @desc Retrieves number of reflection probes added to the environment.
	///
	/// @return {Real} The number of reflection probes added to the environment.
	static get_reflection_probe_count = function ()
	{
		gml_pragma("forceinline");
		return array_length(ReflectionProbes);
	};

	/// @func get_reflection_probe(_index)
	///
	/// @desc Retrieves a reflection probe at given index.
	///
	/// @param {Real} _index The index of the reflection probe.
	///
	/// @return {Struct.BBMOD_ReflectionProbe} The reflection probe at given
	/// index.
	static get_reflection_probe = function (_index)
	{
		gml_pragma("forceinline");
		return ReflectionProbes[_index];
	};

	/// @func find_reflection_probe(_position)
	///
	/// @desc Finds a reflection probe in the environment that influences given
	/// position.
	///
	/// @param {Struct.BBMOD_Vec3} _position The position to find a reflection
	/// probe at.
	///
	/// @return {Struct.BBMOD_ReflectionProbe, Undefined} The found reflection
	/// probe or `undefined`.
	static find_reflection_probe = function (_position)
	{
		// TODO: Use spatial index for reflection probes
		gml_pragma("forceinline");
		var _reflectionProbes = ReflectionProbes;
		var _probe = undefined;
		var _probeVolume = infinity;
		var i = 0;
		repeat(array_length(_reflectionProbes))
		{
			with(_reflectionProbes[i++])
			{
				if (!Enabled)
				{
					continue;
				}
				if (Infinite)
				{
					return self;
				}
				var _min = Position.Sub(Size);
				if (_position.X < _min.X
					|| _position.Y < _min.Y
					|| _position.Z < _min.Z)
				{
					continue;
				}
				var _max = Position.Add(Size);
				if (_position.X > _max.X
					|| _position.Y > _max.Y
					|| _position.Z > _max.Z)
				{
					continue;
				}
				if (__volume < _probeVolume)
				{
					_probe = self;
					_probeVolume = __volume;
				}
			}
		}
		return _probe;
	};

	/// @func remove_reflection_probe(_reflectionProbe)
	///
	/// @desc Removes a reflection probe at given index from the environment.
	///
	/// @param {Struct.BBMOD_ReflectionProbe} _reflectionProbe The reflection
	/// probe to remove.
	///
	/// @return {Bool} Returns `true` if the probe was removed of `false` if the
	/// probe was not found in the environment.
	static remove_reflection_probe = function (_reflectionProbe)
	{
		gml_pragma("forceinline");
		var _reflectionProbes = ReflectionProbes;
		var i = 0;
		repeat(array_length(_reflectionProbes))
		{
			if (_reflectionProbes[i] == _reflectionProbe)
			{
				array_delete(_reflectionProbes, i, 1);
				return true;
			}
			++i;
		}
		return false;
	};

	/// @func remove_reflection_probe_index(_index)
	///
	/// @desc Removes a reflection probe at given index from the environment.
	///
	/// @param {Real} _index The index to remove the reflection probe at.
	///
	/// @return {Struct.BBMOD_Environment} Returns `self`.
	static remove_reflection_probe_index = function (_index)
	{
		gml_pragma("forceinline");
		array_delete(ReflectionProbes, _index, 1);
		return self;
	};

	/// @func clear_reflection_probes()
	///
	/// @desc Removes all reflection probes added to the environment.
	///
	/// @return {Struct.BBMOD_Environment} Returns `self`.
	static clear_reflection_probes = function ()
	{
		gml_pragma("forceinline");
		ReflectionProbes = [];
		return self;
	};

	/// @func clear()
	///
	/// @desc Resets the environment to the default state, destroys everything it
	/// contains.
	///
	/// @return {Struct.BBMOD_Environment} Returns `self`.
	static clear = function ()
	{
		AmbientLightDirection = BBMOD_VEC3_UP;
		AmbientLightColorUp = BBMOD_C_WHITE;
		AmbientLightColorDown = BBMOD_C_GRAY;
		AmbientLightAffectLightmaps = true;
		Lightmap = sprite_get_texture(BBMOD_SprBlack, 0);
		LightDirectional = undefined;
		LightsPunctual = [];
		ImageBasedLight = undefined;

		for (var i = array_length(ReflectionProbes) - 1; i >= 0; --i)
		{
			ReflectionProbes[i].destroy();
		}
		ReflectionProbes = [];

		FogColor = BBMOD_C_WHITE;
		FogIntensity = 0.0;
		FogStart = 0.0;
		FogEnd = 1.0;

		return self;
	};

	/// @func destroy()
	///
	/// @desc Destroys the environment and everything it contains.
	///
	/// @return {Undefined} Returns `undefined`.
	///
	/// @note Trying to destroy the default environment will end with an error!
	///
	/// @see bbmod_environment_get_default
	static destroy = function ()
	{
		bbmod_assert(bbmod_environment_get_default() != self, "Cannot destroy the default environment!");
		clear();
		return undefined;
	};
}

/// @func bbmod_environment_get_default()
///
/// @desc Retrieves the default environment.
///
/// @return {Struct.BBMOD_Environment} The default environment.
///
/// @note The default environment cannot be destroyed!
///
/// @see bbmod_environment_get_current
/// @see bbmod_environment_set_current
function bbmod_environment_get_default()
{
	gml_pragma("forceinline");
	static _env = new BBMOD_Environment();
	return _env;
}

/// @func bbmod_environment_get_current()
///
/// @desc Retrieves the current environment.
///
/// @return {Struct.BBMOD_Environment} The current environment. The default one
/// is returned if a user environment has not been defined previously with
/// {@link bbmod_environment_set_current}.
///
/// @see bbmod_environment_get_default
function bbmod_environment_get_current()
{
	gml_pragma("forceinline");
	return (global.__bbmodEnvCurrent ?? bbmod_environment_get_default());
}


/// @func bbmod_environment_set_current(_env)
///
/// @desc Changes the current environment.
///
/// @param {Struct.BBMOD_Environment} _env The new environment or `undefiend`
/// to use the default one.
///
/// @see bbmod_environment_get_default
/// @see bbmod_environment_get_current
function bbmod_environment_set_current(_env)
{
	gml_pragma("forceinline");
	global.__bbmodEnvCurrent = _env;
}
