/// @module Core

/// @var {Struct.BBMOD_Scene} The scene that's currently being updated or
/// rendered.
/// @private
global.__bbmodSceneCurrent = undefined;

/// @func BBMOD_Scene([_name])
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Used to compose models, terrain, lights, particle effects, cameras
/// etc. into a single scene.
///
/// @param {String, Undefined} [_name] The name of the scene or `undefined`, in
/// which case its generated.
///
/// @see BBMOD_SceneNode
function BBMOD_Scene(_name=undefined) constructor
{
	static __sceneCounter = 0;

	/// @var {String} The name of the scene.
	Name = _name ?? $"Scene{__sceneCounter++}";

	/// @var {Struct.BBMOD_SceneNode}
	/// @readonly
	RootNode = new BBMOD_SceneNode("RootNode");

	RootNode.__scene = self;

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

	/// @var {Pointer.Texture} A lightmap applied to the whole scene.
	/// @readonly
	Lightmap = sprite_get_texture(BBMOD_SprBlack, 0);

	/// @var {Struct.BBMOD_DirectionalLight, Undefined} A directional light
	/// applied to the whole scene. Defaults to `undefined`.
	LightDirectional = undefined;

	/// @var {Array<Struct.BBMOD_PunctualLight>} An array of punctual lights
	/// added to the scene.
	/// @readonly
	LightsPunctual = [];

	/// @var {Struct.BBMOD_ImageBasedLight, Undefined} The image-based light
	/// applied to the whole scene. Defaults to `undefined`.
	/// @readonly
	ImageBasedLight = undefined;

	/// @var {Array<Struct.BBMOD_ReflectionProbe>} An array of reflection probes
	/// added to the scene.
	/// @readonly
	ReflectionProbes = [];

	/// @var {Struct.BBMOD_Color} The color of the fog. Defaults to
	/// {@link BBMOD_C_WHITE}.
	FogColor = BBMOD_C_WHITE;

	/// @var {Real} The maximum intensity the fog. Use 0 (default) to disable
	/// fog.
	FogIntensity = 0.0;

	/// @var {Real} The distance from the camera at which the fog starts.
	/// @see BBMOD_Scene.FogEnd
	FogStart = 0.0;

	/// @var {Real} The distance from the camera at which the fog reaches its
	/// maximum intensity.
	/// @see BBMOD_Scene.FogStart
	/// @see BBMOD_Scene.FogIntensity
	FogEnd = 1.0;

	/// @var {Array<Struct.BBMOD_BaseCamera>} An array of cameras added to the
	/// scene.
	/// @readonly
	Cameras = [];

	/// @var {Struct.BBMOD_BaseCamera, Undefined} The currently active camera.
	/// Defaults to `undefined` (no camera).
	CameraCurrent = undefined;

	/// @var {Struct.BBMOD_ResourceManager} The resource manager used by the
	/// scene for loading resources. Defaults to {@link BBMOD_RESOURCE_MANAGER}.
	ResourceManager = BBMOD_RESOURCE_MANAGER;

	/// @func add_punctual_light(_light)
	///
	/// @desc Adds a punctual light to the scene.
	///
	/// @param {Struct.BBMOD_PunctualLight} _light The light to add.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static add_punctual_light = function (_light)
	{
		gml_pragma("forceinline");
		array_push(LightsPunctual, _light);
		return self;
	};

	/// @func get_punctual_light_count()
	///
	/// @desc Retrieves number of punctual lights added to the scene.
	///
	/// @return {Real} The number of punctual lights added to the scene.
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
	/// @desc Removes a punctual light from the scene.
	///
	/// @param {Struct.BBMOD_PunctualLight} _light The light to remove.
	///
	/// @return {Bool} Returns `true` if the light was removed or `false` if the
	/// light was not found in the scene.
	static remove_punctual_light = function (_light)
	{
		var _punctualLights = LightsPunctual;
		var i = 0;
		repeat (array_length(_punctualLights))
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
	/// @desc Removes a punctual light at given index from the scene.
	///
	/// @param {Real} _index The index to remove the light at.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static remove_punctual_light_index = function (_index)
	{
		gml_pragma("forceinline");
		array_delete(LightsPunctual, _index, 1);
		return self;
	};

	/// @func clear_punctual_lights(_index)
	///
	/// @desc Removes all punctual lights added to the scene.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static clear_punctual_lights = function ()
	{
		gml_pragma("forceinline");
		LightsPunctual = [];
		return self;
	};

	/// @func add_reflection_probe(_reflectionProbe)
	///
	/// @desc Adds a reflection probe to the scene.
	///
	/// @param {Struct.BBMOD_ReflectionProbe} _reflectionProbe The reflection
	/// probe to add.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static add_reflection_probe = function (_reflectionProbe)
	{
		gml_pragma("forceinline");
		array_push(ReflectionProbes, _reflectionProbe);
		return self;
	};

	/// @func get_reflection_probe_count()
	///
	/// @desc Retrieves number of reflection probes added to the scene.
	///
	/// @return {Real} The number of reflection probes added to the scene.
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
	/// @desc Finds a reflection probe in the scene that influences given
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
		repeat (array_length(_reflectionProbes))
		{
			with (_reflectionProbes[i++])
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
	/// @desc Removes a reflection probe at given index from the scene.
	///
	/// @param {Struct.BBMOD_ReflectionProbe} _reflectionProbe The reflection
	/// probe to remove.
	///
	/// @return {Bool} Returns `true` if the probe was removed of `false` if the
	/// probe was not found in the scene.
	static remove_reflection_probe = function (_reflectionProbe)
	{
		gml_pragma("forceinline");
		var _reflectionProbes = ReflectionProbes;
		var i = 0;
		repeat (array_length(_reflectionProbes))
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
	/// @desc Removes a reflection probe at given index from the scene.
	///
	/// @param {Real} _index The index to remove the reflection probe at.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static remove_reflection_probe_index = function (_index)
	{
		gml_pragma("forceinline");
		array_delete(ReflectionProbes, _index, 1);
		return self;
	};

	/// @func clear_reflection_probes()
	///
	/// @desc Removes all reflection probes added to the scene.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static clear_reflection_probes = function ()
	{
		gml_pragma("forceinline");
		ReflectionProbes = [];
		return self;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Updates the whole scene.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static update = function (_deltaTime)
	{
		global.__bbmodSceneCurrent = self;
		if (CameraCurrent != undefined)
		{
			CameraCurrent.update(delta_time);
		}
		RootNode.update(delta_time);
		return self;
	};

	/// @func submit()
	///
	/// @desc Immediately submits the whole scene for rendering.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static submit = function ()
	{
		global.__bbmodSceneCurrent = self;
		if (CameraCurrent != undefined)
		{
			CameraCurrent.apply();
		}
		RootNode.submit();
		bbmod_material_reset();
		return self;
	};

	/// @func render()
	///
	/// @desc Enqueues the whole scene for rendering.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static render = function ()
	{
		global.__bbmodSceneCurrent = self;
		if (CameraCurrent != undefined)
		{
			CameraCurrent.apply();
		}
		RootNode.render();
		return self;
	};

	/// @func clear()
	///
	/// @desc Resets the scene to the default state, destroys everything it
	/// contains and frees all loaded resources.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static clear = function ()
	{
		RootNode.destroy();
		RootNode = new BBMOD_SceneNode("RootNode");

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

		Cameras = [];
		CameraCurrent = undefined;

		ResourceManager.clear();
		ResourceManager = BBMOD_RESOURCE_MANAGER;

		return self;
	};

	/// @func destroy()
	///
	/// @desc Destroys the scene and everything it contains and frees all loaded
	/// resources.
	///
	/// @return {Undefined} Returns `undefined`.
	///
	/// @note Trying to destroy the default scene will end with an error!
	///
	/// @see bbmod_scene_get_default
	static destroy = function ()
	{
		bbmod_assert(bbmod_scene_get_default() != self, "Cannot destroy the default scene!");
		clear();
		return undefined;
	};
}

/// @func bbmod_scene_get_default()
///
/// @desc Retrieves the default scene.
///
/// @return {Struct.BBMOD_Scene} The default scene.
///
/// @note The default scene cannot be destroyed!
function bbmod_scene_get_default()
{
	gml_pragma("forceinline");
	static _scene = new BBMOD_Scene();
	return _scene;
}

/// @func bbmod_scene_get_current()
///
/// @desc Retrieves the scene that is currently being updated or rendered. If
/// there is no such scene, the default scene is returned.
///
/// @return {Struct.BBMOD_Scene} The current scene.
///
/// @see bbmod_scene_get_default
function bbmod_scene_get_current()
{
	gml_pragma("forceinline");
	return (global.__bbmodSceneCurrent ?? bbmod_scene_get_default());
}
