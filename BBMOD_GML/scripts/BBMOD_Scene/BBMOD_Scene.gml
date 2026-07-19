/// @module Core

/// @var {Struct.BBMOD_Scene} The current scene.
/// @private
global.__bbmodSceneCurrent = undefined;

/// @func BBMOD_Scene()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Owns scene nodes and scene-wide rendering state.
function BBMOD_Scene() constructor
{
	/// @var {Array<Struct.BBMOD_SceneNode>} Root scene nodes.
	/// @readonly
	RootNodes = [];

	/// @var {Array<Struct.BBMOD_SceneNode>} Flat array of all scene nodes.
	/// @readonly
	Nodes = [];

	/// @var {Array<Array<Struct.BBMOD_SceneNode>>} Flat node arrays by kind.
	/// @readonly
	NodesByKind = [];

	/// @var {Array<Struct.BBMOD_BaseCamera>} Cameras added to the scene.
	/// @readonly
	Cameras = [];

	/// @var {Array<Struct.BBMOD_Model>} Models added to the scene.
	/// @readonly
	Models = [];

	/// @var {Struct.BBMOD_BaseCamera, Undefined} The current camera.
	CameraCurrent = undefined;

	/// @var {Struct.BBMOD_DirectionalLight, Undefined} Directional light.
	LightDirectional = undefined;

	/// @var {Array<Struct.BBMOD_PunctualLight>} Punctual lights in the scene.
	/// @readonly
	LightsPunctual = [];

	/// @var {Array<Struct.BBMOD_ReflectionProbe>} Reflection probes in the scene.
	/// @readonly
	ReflectionProbes = [];

	/// @var {Array<Struct.BBMOD_ParticleEmitter>} Particle emitters in the scene.
	/// @readonly
	ParticleEmitters = [];

	/// @var {Array<Struct.BBMOD_Terrain>} Terrains in the scene.
	/// @readonly
	Terrains = [];

	/// @var {Array<Struct.BBMOD_LensFlare>} Lens flares in the scene.
	/// @readonly
	LensFlares = [];

	/// @var {Struct.BBMOD_ImageBasedLight, Undefined} Scene image-based light.
	ImageBasedLight = undefined;

	/// @var {Pointer.Texture} Scene lightmap texture.
	Lightmap = sprite_get_texture(BBMOD_SprBlack, 0);

	/// @var {Struct.BBMOD_Vec3} Ambient light upper hemisphere direction.
	AmbientLightDirection = BBMOD_VEC3_UP;

	/// @var {Struct.BBMOD_Color} Ambient light upper hemisphere color.
	AmbientLightColorUp = BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Color} Ambient light lower hemisphere color.
	AmbientLightColorDown = BBMOD_C_GRAY;

	/// @var {Bool} Whether ambient light affects lightmapped models.
	AmbientLightAffectLightmaps = true;

	/// @var {Struct.BBMOD_Color} Fog color.
	FogColor = BBMOD_C_WHITE;

	/// @var {Real} Fog intensity.
	FogIntensity = 0.0;

	/// @var {Real} Fog start distance.
	FogStart = 0.0;

	/// @var {Real} Fog end distance.
	FogEnd = 1.0;

	repeat(BBMOD_ESceneNodeType.Custom + 1)
	{
		array_push(NodesByKind, []);
	}

	static __array_add_unique = function (_array, _value)
	{
		var i = 0;
		repeat(array_length(_array))
		{
			if (_array[i++] == _value)
			{
				return false;
			}
		}
		array_push(_array, _value);
		return true;
	};

	static __add_root_node = function (_node)
	{
		return __array_add_unique(RootNodes, _node);
	};

	static __remove_root_node = function (_node)
	{
		return bbmod_array_remove(RootNodes, _node);
	};

	static __add_typed_node = function (_node)
	{
		var _kind = _node.SceneNodeKind;
		__array_add_unique(NodesByKind[_kind], _node);

		switch (_kind)
		{
			case BBMOD_ESceneNodeType.Camera:
				__array_add_unique(Cameras, _node);
				if (CameraCurrent == undefined)
				{
					CameraCurrent = _node;
				}
				break;

			case BBMOD_ESceneNodeType.Model:
				__array_add_unique(Models, _node);
				break;

			case BBMOD_ESceneNodeType.PointLight:
			case BBMOD_ESceneNodeType.SpotLight:
				__array_add_unique(LightsPunctual, _node);
				break;

			case BBMOD_ESceneNodeType.DirectionalLight:
				LightDirectional = _node;
				break;

			case BBMOD_ESceneNodeType.ReflectionProbe:
				__array_add_unique(ReflectionProbes, _node);
				break;

			case BBMOD_ESceneNodeType.ParticleEmitter:
				__array_add_unique(ParticleEmitters, _node);
				break;

			case BBMOD_ESceneNodeType.Terrain:
				__array_add_unique(Terrains, _node);
				break;

			case BBMOD_ESceneNodeType.LensFlare:
				__array_add_unique(LensFlares, _node);
				break;
		}
	};

	static __remove_typed_node = function (_node)
	{
		var _kind = _node.SceneNodeKind;
		bbmod_array_remove(NodesByKind[_kind], _node);

		switch (_kind)
		{
			case BBMOD_ESceneNodeType.Camera:
				bbmod_array_remove(Cameras, _node);
				if (CameraCurrent == _node)
				{
					CameraCurrent = undefined;
				}
				break;

			case BBMOD_ESceneNodeType.Model:
				bbmod_array_remove(Models, _node);
				break;

			case BBMOD_ESceneNodeType.PointLight:
			case BBMOD_ESceneNodeType.SpotLight:
				bbmod_array_remove(LightsPunctual, _node);
				break;

			case BBMOD_ESceneNodeType.DirectionalLight:
				if (LightDirectional == _node)
				{
					LightDirectional = undefined;
				}
				break;

			case BBMOD_ESceneNodeType.ReflectionProbe:
				bbmod_array_remove(ReflectionProbes, _node);
				break;

			case BBMOD_ESceneNodeType.ParticleEmitter:
				bbmod_array_remove(ParticleEmitters, _node);
				break;

			case BBMOD_ESceneNodeType.Terrain:
				bbmod_array_remove(Terrains, _node);
				break;

			case BBMOD_ESceneNodeType.LensFlare:
				bbmod_array_remove(LensFlares, _node);
				break;
		}
	};

	static __register_node_tree = function (_node)
	{
		if (_node.Scene == self)
		{
			return self;
		}

		if (_node.Scene != undefined)
		{
			_node.Scene.remove_node(_node);
		}

		_node.Scene = self;
		__array_add_unique(Nodes, _node);
		__add_typed_node(_node);

		var _children = _node.Children;
		var i = 0;
		repeat(array_length(_children))
		{
			__register_node_tree(_children[i++]);
		}

		return self;
	};

	static __unregister_node_tree = function (_node)
	{
		var _children = _node.Children;
		var i = 0;
		repeat(array_length(_children))
		{
			__unregister_node_tree(_children[i++]);
		}

		__remove_typed_node(_node);
		bbmod_array_remove(Nodes, _node);
		_node.Scene = undefined;
		return self;
	};

	static __detach_node_from_parent = function (_node)
	{
		var _parent = _node.Parent;
		if (_parent == undefined)
		{
			return self;
		}

		bbmod_array_remove(_parent.Children, _node);
		_node.Parent = undefined;
		_parent.mark_transform_dirty();
		return self;
	};

	/// @func add_node(_node)
	///
	/// @desc Adds a node and its descendants to the scene.
	///
	/// @param {Struct.BBMOD_SceneNode} _node The node to add.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static add_node = function (_node)
	{
		if (_node.Parent == undefined)
		{
			__add_root_node(_node);
		}
		else
		{
			__remove_root_node(_node);
		}

		__register_node_tree(_node);
		_node.mark_transform_dirty();
		return self;
	};

	/// @func remove_node(_node)
	///
	/// @desc Removes a node and its descendants from the scene without destroying
	/// them.
	///
	/// @param {Struct.BBMOD_SceneNode} _node The node to remove.
	///
	/// @return {Bool} Returns `true` if the node was removed.
	static remove_node = function (_node)
	{
		if (_node.Scene != self)
		{
			return false;
		}

		__detach_node_from_parent(_node);

		__remove_root_node(_node);
		__unregister_node_tree(_node);
		_node.mark_transform_dirty();
		return true;
	};

	/// @func has_node(_node)
	///
	/// @desc Checks whether a node belongs to the scene.
	///
	/// @param {Struct.BBMOD_SceneNode} _node The node to check.
	///
	/// @return {Bool} Returns `true` if the node belongs to the scene.
	static has_node = function (_node)
	{
		return (_node.Scene == self);
	};

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
		return add_node(_light);
	};

	/// @func get_punctual_light_count()
	///
	/// @desc Retrieves the number of punctual lights in the scene.
	///
	/// @return {Real} The number of punctual lights in the scene.
	static get_punctual_light_count = function ()
	{
		gml_pragma("forceinline");
		return array_length(LightsPunctual);
	};

	/// @func get_punctual_light(_index)
	///
	/// @desc Retrieves a punctual light at the given index.
	///
	/// @param {Real} _index The index of the punctual light.
	///
	/// @return {Struct.BBMOD_PunctualLight} The punctual light.
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
	/// @return {Bool} Returns `true` if the light was removed.
	static remove_punctual_light = function (_light)
	{
		gml_pragma("forceinline");
		return remove_node(_light);
	};

	/// @func remove_punctual_light_index(_index)
	///
	/// @desc Removes a punctual light at the given index from the scene.
	///
	/// @param {Real} _index The index of the light to remove.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static remove_punctual_light_index = function (_index)
	{
		gml_pragma("forceinline");
		remove_punctual_light(get_punctual_light(_index));
		return self;
	};

	/// @func clear_punctual_lights()
	///
	/// @desc Removes all punctual lights from the scene without destroying them.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static clear_punctual_lights = function ()
	{
		gml_pragma("forceinline");
		while (array_length(LightsPunctual) > 0)
		{
			remove_punctual_light(LightsPunctual[array_length(LightsPunctual) - 1]);
		}
		return self;
	};

	/// @func set_directional_light(_light)
	///
	/// @desc Sets the directional light for the scene.
	///
	/// @param {Struct.BBMOD_DirectionalLight, Undefined} _light The light to use.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static set_directional_light = function (_light)
	{
		gml_pragma("forceinline");
		if (LightDirectional != undefined)
		{
			remove_node(LightDirectional);
		}
		if (_light != undefined)
		{
			add_node(_light);
		}
		return self;
	};

	/// @func add_reflection_probe(_reflectionProbe)
	///
	/// @desc Adds a reflection probe to the scene.
	///
	/// @param {Struct.BBMOD_ReflectionProbe} _reflectionProbe The probe to add.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static add_reflection_probe = function (_reflectionProbe)
	{
		gml_pragma("forceinline");
		return add_node(_reflectionProbe);
	};

	/// @func get_reflection_probe_count()
	///
	/// @desc Retrieves the number of reflection probes in the scene.
	///
	/// @return {Real} The number of reflection probes in the scene.
	static get_reflection_probe_count = function ()
	{
		gml_pragma("forceinline");
		return array_length(ReflectionProbes);
	};

	/// @func get_reflection_probe(_index)
	///
	/// @desc Retrieves a reflection probe at the given index.
	///
	/// @param {Real} _index The index of the reflection probe.
	///
	/// @return {Struct.BBMOD_ReflectionProbe} The reflection probe.
	static get_reflection_probe = function (_index)
	{
		gml_pragma("forceinline");
		return ReflectionProbes[_index];
	};

	/// @func find_reflection_probe(_position)
	///
	/// @desc Finds the smallest enabled reflection probe influencing a position.
	///
	/// @param {Struct.BBMOD_Vec3} _position The position to test.
	///
	/// @return {Struct.BBMOD_ReflectionProbe, Undefined} The found probe.
	static find_reflection_probe = function (_position)
	{
		var _probe = undefined;
		var _probeVolume = infinity;
		var i = 0;
		repeat(array_length(ReflectionProbes))
		{
			with(ReflectionProbes[i++])
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
	/// @desc Removes a reflection probe from the scene.
	///
	/// @param {Struct.BBMOD_ReflectionProbe} _reflectionProbe The probe to remove.
	///
	/// @return {Bool} Returns `true` if the probe was removed.
	static remove_reflection_probe = function (_reflectionProbe)
	{
		gml_pragma("forceinline");
		return remove_node(_reflectionProbe);
	};

	/// @func remove_reflection_probe_index(_index)
	///
	/// @desc Removes a reflection probe at the given index from the scene.
	///
	/// @param {Real} _index The index of the probe to remove.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static remove_reflection_probe_index = function (_index)
	{
		gml_pragma("forceinline");
		remove_reflection_probe(get_reflection_probe(_index));
		return self;
	};

	/// @func clear_reflection_probes()
	///
	/// @desc Removes all reflection probes from the scene without destroying them.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static clear_reflection_probes = function ()
	{
		gml_pragma("forceinline");
		while (array_length(ReflectionProbes) > 0)
		{
			remove_reflection_probe(ReflectionProbes[array_length(ReflectionProbes) - 1]);
		}
		return self;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Updates all scene nodes.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static update = function (_deltaTime)
	{
		var _nodes = Nodes;
		var i = 0;
		repeat(array_length(_nodes))
		{
			_nodes[i++].update(_deltaTime);
		}
		return self;
	};

	/// @func clear_nodes([_destroy])
	///
	/// @desc Removes all nodes from the scene.
	///
	/// @param {Bool} [_destroy] Whether removed nodes should be destroyed.
	/// Defaults to `false`.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static clear_nodes = function (_destroy = false)
	{
		if (_destroy)
		{
			destroy_nodes();
			return self;
		}

		while (array_length(RootNodes) > 0)
		{
			remove_node(RootNodes[array_length(RootNodes) - 1]);
		}

		return self;
	};

	/// @func destroy_nodes()
	///
	/// @desc Destroys all nodes in the scene.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static destroy_nodes = function ()
	{
		while (array_length(RootNodes) > 0)
		{
			RootNodes[array_length(RootNodes) - 1].destroy();
		}
		return self;
	};

	/// @func clear()
	///
	/// @desc Resets the scene to its default state and detaches scene nodes.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static clear = function ()
	{
		clear_nodes(false);

		CameraCurrent = undefined;
		LightDirectional = undefined;
		ImageBasedLight = undefined;
		Lightmap = sprite_get_texture(BBMOD_SprBlack, 0);
		AmbientLightDirection = BBMOD_VEC3_UP;
		AmbientLightColorUp = BBMOD_C_WHITE;
		AmbientLightColorDown = BBMOD_C_GRAY;
		AmbientLightAffectLightmaps = true;
		FogColor = BBMOD_C_WHITE;
		FogIntensity = 0.0;
		FogStart = 0.0;
		FogEnd = 1.0;

		return self;
	};

	/// @func destroy()
	///
	/// @desc Destroys the scene and all scene-owned nodes.
	///
	/// @return {Undefined} Returns `undefined`.
	static destroy = function ()
	{
		bbmod_assert(bbmod_scene_get_default() != self, "Cannot destroy the default scene!");
		destroy_nodes();
		if (global.__bbmodSceneCurrent == self)
		{
			global.__bbmodSceneCurrent = undefined;
		}
		return undefined;
	};
}

/// @func bbmod_scene_get_default()
///
/// @desc Retrieves the default scene.
///
/// @return {Struct.BBMOD_Scene} The default scene.
///
/// @note The default scene cannot be destroyed.
///
/// @see bbmod_scene_get_current
/// @see bbmod_scene_set_current
function bbmod_scene_get_default()
{
	gml_pragma("forceinline");
	static _scene = new BBMOD_Scene();
	return _scene;
}

/// @func bbmod_scene_get_current()
///
/// @desc Retrieves the current scene.
///
/// @return {Struct.BBMOD_Scene} The current scene. The default scene is
/// returned when no user scene has been set.
///
/// @see bbmod_scene_get_default
/// @see bbmod_scene_set_current
function bbmod_scene_get_current()
{
	gml_pragma("forceinline");
	return (global.__bbmodSceneCurrent ?? bbmod_scene_get_default());
}

/// @func bbmod_scene_set_current(_scene)
///
/// @desc Changes the current scene.
///
/// @param {Struct.BBMOD_Scene, Undefined} _scene The scene to make current or
/// `undefined` to use the default scene.
///
/// @return {Undefined} Returns `undefined`.
///
/// @see bbmod_scene_get_default
/// @see bbmod_scene_get_current
function bbmod_scene_set_current(_scene)
{
	gml_pragma("forceinline");
	global.__bbmodSceneCurrent = _scene;
}
