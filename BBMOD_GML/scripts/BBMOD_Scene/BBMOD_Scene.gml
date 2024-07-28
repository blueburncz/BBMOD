/// @module Core

/// @macro {Real} The ID used to tell that a scene node does not exist.
/// @see BBMOD_Scene.Nodes
#macro BBMOD_SCENE_NODE_ID_INVALID 0xFFFFFFFF

/// @macro {Real} The minimum number of node IDs available for reuse until they
/// are actually used again.
/// @private
#macro __BBMOD_SCENE_NODE_ID_REUSE_THRESHOLD 1024

/// @macro {Code} Throws an exception if node with id `_id` does not exist.
/// @private
#macro __BBMOD_CHECK_SCENE_NODE_EXISTS \
	if (!node_exists(_id)) \
	{ \
		throw new BBMOD_Exception($"Node with ID {_id} does not exist!"); \
	}

/// @enum Enumeration of all possible flags that a scene node can have.
/// @see BBMOD_ESceneNode.Flags
enum BBMOD_ESceneNodeFlags
{
	/// @member No flags are set.
	None = 0x0,
	/// @member Whether the node is alive.
	IsAlive = 0x1,
	/// @member The node is set as "visible", i.e. it should be rendered, unless
	/// its ancestor is not visible or the node is culled away (e.g. by frustum
	/// culling).
	IsVisible = 0x2,
	/// @member The node never changes its transformation matrix and does not.
	IsStatic = 0x4,
	/// @member The node's transformation matrix is outdated and needs to be
	/// recomputed.
	IsTransformDirty = 0x8,
	/// @member Whether the node plays a looping animation.
	IsAnimationLooping = 0x10,
};

/// @enum Enumeration of scene node properties.
/// @see BBMOD_Scene.Nodes
enum BBMOD_ESceneNode
{
	/// @member Used to reuse node IDs.
	Generation,
	/// @member The name of the node.
	Name,
	/// @member The ID of the node's parent. Defaults to
	/// {@link BBMOD_SCENE_NODE_ID_INVALID}.
	Parent,
	/// @member An array of child node IDs or `undefined`.
	Children,
	/// @member The node's X component of its position, in local space. Defaults
	/// to 0.
	PositionX,
	/// @member The node's Y component of its position, in local space. Defaults
	/// to 0.
	PositionY,
	/// @member The node's Z component of its position, in local space. Defaults
	/// to 0.
	PositionZ,
	/// @member The node's X component of its position, in global space.
	PositionAbsoluteX,
	/// @member The node's Y component of its position, in global space.
	PositionAbsoluteY,
	/// @member The node's Z component of its position, in global space.
	PositionAbsoluteZ,
	/// @member The node's X component of its rotation (quaternion), in local
	/// space. Defaults to 0.
	RotationX,
	/// @member The node's Y component of its rotation (quaternion), in local
	/// space. Defaults to 0.
	RotationY,
	/// @member The node's Z component of its rotation (quaternion), in local
	/// space. Defaults to 0.
	RotationZ,
	/// @member The node's W component of its rotation (quaternion), in local
	/// space. Defaults to 1.
	RotationW,
	/// @member The node's X component of its rotation (quaternion), in global
	/// space.
	RotationAbsoluteX,
	/// @member The node's Y component of its rotation (quaternion), in global
	/// space.
	RotationAbsoluteY,
	/// @member The node's Z component of its rotation (quaternion), in global
	/// space.
	RotationAbsoluteZ,
	/// @member The node's W component of its rotation (quaternion), in global
	/// space.
	RotationAbsoluteW,
	/// @member The node's X component of its scaling factor, in local space.
	/// Defaults to 1.
	ScaleX,
	/// @member The node's Y component of its scaling factor, in local space.
	/// Defaults to 1.
	ScaleY,
	/// @member The node's Z component of its scaling factor, in local space.
	/// Defaults to 1.
	ScaleZ,
	/// @member The node's X component of its scaling factor, in global space.
	ScaleAbsoluteX,
	/// @member The node's Y component of its scaling factor, in global space.
	ScaleAbsoluteY,
	/// @member The node's Z component of its scaling factor, in global space.
	ScaleAbsoluteZ,
	/// @member The node's local transformation matrix.
	Transform,
	/// @member The node's global transformation matrix.
	TransfromAbsolute,
	/// @member The path to the model that the node renders or `undefined`
	/// (default).
	Model,
	/// @member An array of materials that override the ones used by the node's
	/// model or `undefined` (default).
	Materials,
	/// @member A {@link BBMOD_MaterialPropertyBlock} associated with the node
	/// or `undefined` (default).
	MaterialProps,
	/// @member The node's animation player or `undefined` (default).
	AnimationPlayer,
	/// @member The path to the currently played animation or `undefined`
	/// (default).
	Animation,
	/// @member The maximum distance from the current camera at which the node
	/// is rendered. Defaults to `infinity`.
	RenderDistance,
	/// @member Node flags. Defaults to {@link BBMOD_ESceneNodeFlags.IsAlive},
	/// {@link BBMOD_ESceneNodeFlags.IsVisible} and
	/// {@link BBMOD_ESceneNodeFlags.IsTransformDirty}.
	Flags,
	/// @member Total number of members of this enum.
	SIZE
};

/// @func BBMOD_SceneNodeDescriptor()
///
/// @desc A struct used in {@link BBMOD_Scene.create_node} to create a new scene
/// node.
function BBMOD_SceneNodeDescriptor() constructor
{
	/// @var {String, Undefined} The name of the node to be created or
	/// `undefined`, in which case it is generated automatically.
	Name = undefined;

	/// @var {Real} The ID of the parent node of the node to be created.
	/// Defaults to {@link BBMOD_SCENE_NODE_ID_INVALID} (no parent).
	Parent = BBMOD_SCENE_NODE_ID_INVALID;

	/// @var {Struct.BBMOD_Vec3, Undefined} The position of the node to be
	/// created, in local space (i.e. relative to its parent). Defaults to
	/// `(0, 0, 0)` if `undefined`.
	Position = undefined;

	/// @var {Struct.BBMOD_Quaternion, Undefined} The rotation (quaternion) of
	/// the node to be created, in local space (i.e. relative to its parent).
	/// Defaults to `(0, 0, 0, 1)` if `undefined`.
	Rotation = undefined;

	/// @var {Struct.BBMOD_Vec3, Undefined} The rotation of the node to be
	/// created, in local space (i.e. relative to its parent). Defaults to
	/// `(1, 1, 1)` if `undefined`.
	Scale = undefined;

	/// @var {String, Undefined} The path to the model that the node to be
	/// created will draw. Defaults to `undefined`.
	Model = undefined;

	/// @var {Array<Struct.BBMOD_Material>, Undefined} An array of materials
	/// that the node to be created will use to override the ones defined in its
	/// model. Defaults to `undefined`.
	Materials = undefined;

	/// @var {Struct.BBMOD_MaterialPropertyBlock, Undefined} A material property
	/// block associated with the node to be created or `undefined` (default).
	MaterialProps = undefined;

	/// @var {String, Undefined} The path to the animation which the node will
	/// start playing on creation. Defaults to `undefined`.
	Animation = undefined;

	/// @var {Bool} Whether the node to be created plays its animation in a
	/// loop. Defaults to `false`.
	AnimationLoops = false;

	/// @var {Real} The maximum distance from the camera at which the node to be
	/// created can be rendered. Defaults to `infinity` (unlimited rendering
	/// distance).
	RenderDistance = infinity;

	/// @var {Bool} Whether the node to be created is visible or not. Defaults
	/// to `true`.
	IsVisible = true;

	/// @var {Bool} Whether the node to be created is static, i.e. it never
	/// changes its transformation matrix. Defaults to `false`.
	IsStatic = false;
}

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
	static __nodeSpaceInitial = 1000;

	/// @var {String} The name of the scene.
	Name = _name ?? $"Scene{__sceneCounter++}";

	/// @var {Id.DsGrid} A grid used to store node properties.
	/// @readonly
	Nodes = ds_grid_create(BBMOD_ESceneNode.SIZE, __nodeSpaceInitial);

	/// @var {Real} Used to generate names of created nodes.
	/// @private
	__nodeCounter = 0;

	/// @var {Real} The index used for the next created node, if no indices are
	/// available for reuse.
	/// @readonly
	__nodeIndexNext = 0;

	/// @var {Array<Real>} Indices available for reuse once their minimum
	/// required number is reached.
	/// @see __BBMOD_SCENE_NODE_ID_REUSE_THRESHOLD
	/// @private
	__nodeIndicesAvailable = [];

	clear_nodes();

	/// @var {Struct.BBMOD_Terrain, Undefined} The scene's terrain.
	Terrain = undefined;

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

	/// @func create_node([_descriptor])
	///
	/// @desc Creates a new scene node.
	///
	/// @param {Struct.BBMOD_SceneNodeDescriptor, Undefined} [_descriptor] The
	/// description of the node to be created. If not provided, default values
	/// are used.
	///
	/// @return {Real} Returns the ID of the created node.
	///
	/// @throws {BBMOD_Exception} If given descriptor contains invalid data.
	///
	/// @note The maximum number of nodes existing at a time is 2^24. In the
	/// very unlikely case we run out of node IDs, this function returns
	/// {@link BBMOD_SCENE_NODE_ID_INVALID}, which means the node was not
	/// created!
	static create_node = function (_descriptor=undefined)
	{
		var _index;
		if (array_length(__nodeIndicesAvailable) < __BBMOD_SCENE_NODE_ID_REUSE_THRESHOLD)
		{
			if (__nodeIndexNext < 0xFFFFFF)
			{
				_index = __nodeIndexNext++;
			}
			else
			{
				// Run out of node IDs!
				return BBMOD_SCENE_NODE_ID_INVALID;
			}
		}
		else
		{
			_index = __nodeIndicesAvailable[0];
			array_delete(__nodeIndicesAvailable, 0, 1);
		}

		var _id = ((Nodes[# BBMOD_ESceneNode.Generation, _index] << 24) | _index);
		var _flags = (BBMOD_ESceneNodeFlags.IsAlive
			| BBMOD_ESceneNodeFlags.IsTransformDirty);

		Nodes[# BBMOD_ESceneNode.Name, _index] = 
			(_descriptor ? _descriptor[$ "Name"] : undefined) ?? $"Node {__nodeCounter++}";

		// Set parent:
		var _parent = (_descriptor ? _descriptor[$ "Parent"] : undefined) ?? BBMOD_SCENE_NODE_ID_INVALID;
		Nodes[# BBMOD_ESceneNode.Parent, _index] = _parent;

		// Add self to parent:
		if (_parent != BBMOD_SCENE_NODE_ID_INVALID)
		{
			if (!node_exists(_parent))
			{
				throw new BBMOD_Exception($"Invalid parent with ID {_parent} - node does not exist!");
			}
			var _children = Nodes[# BBMOD_ESceneNode.Children, _parent & 0xFFFFFF];
			if (_children == undefined)
			{
				_children = [];
				Nodes[# BBMOD_ESceneNode.Children, _parent & 0xFFFFFF] = _children;
			}
			array_push(_children, _id);
		}

		Nodes[# BBMOD_ESceneNode.Children, _index] = undefined;

		var _position = _descriptor ? _descriptor[$ "Position"] : undefined;
		if (_position != undefined)
		{
			Nodes[# BBMOD_ESceneNode.PositionX, _index] = _position.X;
			Nodes[# BBMOD_ESceneNode.PositionY, _index] = _position.Y;
			Nodes[# BBMOD_ESceneNode.PositionZ, _index] = _position.Z;
		}
		else
		{
			Nodes[# BBMOD_ESceneNode.PositionX, _index] = 0.0;
			Nodes[# BBMOD_ESceneNode.PositionY, _index] = 0.0;
			Nodes[# BBMOD_ESceneNode.PositionZ, _index] = 0.0;
		}

		var _rotation = _descriptor ? _descriptor[$ "Rotation"] : undefined;
		if (_rotation != undefined)
		{
			Nodes[# BBMOD_ESceneNode.RotationX, _index] = _rotation.X;
			Nodes[# BBMOD_ESceneNode.RotationY, _index] = _rotation.Y;
			Nodes[# BBMOD_ESceneNode.RotationZ, _index] = _rotation.Z;
			Nodes[# BBMOD_ESceneNode.RotationW, _index] = _rotation.W;
		}
		else
		{
			Nodes[# BBMOD_ESceneNode.RotationX, _index] = 0.0;
			Nodes[# BBMOD_ESceneNode.RotationY, _index] = 0.0;
			Nodes[# BBMOD_ESceneNode.RotationZ, _index] = 0.0;
			Nodes[# BBMOD_ESceneNode.RotationW, _index] = 1.0;
		}

		var _scale = _descriptor ? _descriptor[$ "Scale"] : undefined;
		if (_rotation != undefined)
		{
			Nodes[# BBMOD_ESceneNode.ScaleX, _index] = _scale.X;
			Nodes[# BBMOD_ESceneNode.ScaleY, _index] = _scale.Y;
			Nodes[# BBMOD_ESceneNode.ScaleZ, _index] = _scale.Z;
		}
		else
		{
			Nodes[# BBMOD_ESceneNode.ScaleX, _index] = 1.0;
			Nodes[# BBMOD_ESceneNode.ScaleY, _index] = 1.0;
			Nodes[# BBMOD_ESceneNode.ScaleZ, _index] = 1.0;
		}

		Nodes[# BBMOD_ESceneNode.Transform, _index] = new BBMOD_Matrix();
		Nodes[# BBMOD_ESceneNode.TransfromAbsolute, _index] = new BBMOD_Matrix();
		Nodes[# BBMOD_ESceneNode.Model, _index] =
			_descriptor ? _descriptor[$ "Model"] : undefined;
		Nodes[# BBMOD_ESceneNode.Materials, _index] =
			_descriptor ? _descriptor[$ "Materials"] : undefined;
		Nodes[# BBMOD_ESceneNode.MaterialProps, _index] =
			_descriptor ? _descriptor[$ "MaterialProps"] : undefined;
		Nodes[# BBMOD_ESceneNode.AnimationPlayer, _index] = undefined;
		Nodes[# BBMOD_ESceneNode.Animation, _index] =
			_descriptor ? _descriptor[$ "Animation"] : undefined;

		if (_descriptor && _descriptor[$ "AnimationLoops"] ?? false)
		{
			_flags |= BBMOD_ESceneNodeFlags.IsAnimationLooping;
		}

		Nodes[# BBMOD_ESceneNode.RenderDistance, _index] =
			_descriptor ? _descriptor[$ "RenderDistance"] : infinity;

		if (!_descriptor || _descriptor[$ "IsVisible"] ?? true)
		{
			_flags |= BBMOD_ESceneNodeFlags.IsVisible;
		}

		Nodes[# BBMOD_ESceneNode.Flags, _index] = _flags;

		return _id;
	};

	/// @func node_exists(_id)
	///
	/// @desc Checks whether node with given ID exists.
	///
	/// @param {Real} _id The ID of the node.
	///
	/// @return {Bool} Returns `true` if a node with given ID exists.
	static node_exists = function (_id)
	{
		gml_pragma("forceinline");
		var _index = _id & 0xFFFFFF;
		var _generation = (_id >> 24) & 0xFF;
		return (_id != BBMOD_SCENE_NODE_ID_INVALID
			&& _index >= 0 && _index < __nodeIndexNext
			&& Nodes[# BBMOD_ESceneNode.Generation, _index] == _generation
			&& (Nodes[# BBMOD_ESceneNode.Flags, _index] & BBMOD_ESceneNodeFlags.IsAlive) != 0);
	};

	/// @func destroy_node(_id)
	///
	/// @desc Destroys a node with given ID.
	///
	/// @param {Real} _id The ID of the node to destroy.
	///
	/// @returns {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static destroy_node = function (_id)
	{
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		Nodes[# BBMOD_ESceneNode.Generation, _index] =
			(Nodes[# BBMOD_ESceneNode.Generation, _index] + 1) & 0xFF;
		Nodes[# BBMOD_ESceneNode.AnimationPlayer, _index] = undefined;
		Nodes[# BBMOD_ESceneNode.Flags, _index] = BBMOD_ESceneNodeFlags.None;
		// TODO: Destroy child nodes
		return self;
	};

	/// @func clear_nodes()
	///
	/// @desc Destroys all nodes added to the scene.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @note Please note that this invalides IDs of all existing nodes and you
	/// should not use them anymore!
	static clear_nodes = function ()
	{
		ds_grid_resize(Nodes, BBMOD_ESceneNode.SIZE, __nodeSpaceInitial);
		ds_grid_set_region(
			Nodes,
			BBMOD_ESceneNode.Generation, 0,
			BBMOD_ESceneNode.Generation, __nodeSpaceInitial - 1,
			0);
		ds_grid_set_region(
			Nodes,
			BBMOD_ESceneNode.Flags, 0,
			BBMOD_ESceneNode.Flags, __nodeSpaceInitial - 1,
			BBMOD_ESceneNodeFlags.None);
		__nodeIndexNext = 0;
		__nodeIndicesAvailable = [];
		return self;
	};

	/// @func get_node_name(_id)
	///
	/// @desc Retrieves the name of a node with given ID.
	///
	/// @return {String} The name of the node.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_node_name = function (_id)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		return Nodes[# BBMOD_ESceneNode.Name, _id & 0xFFFFFF];
	};

	/// @func set_node_name(_id, _name)
	///
	/// @desc Changes the name of a node with given ID.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {String} _name The new name of the node.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static set_node_name = function (_id, _name)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		Nodes[# BBMOD_ESceneNode.Name, _id & 0xFFFFFF] = _name;
		return self;
	};

	/// @func get_node_parent(_id)
	///
	/// @desc Retrieves the parent's ID of given node.
	///
	/// @param {Real} _id The ID of the node.
	///
	/// @return {Real} The ID of the parent node or
	/// {@link BBMOD_SCENE_NODE_ID_INVALID} if given node does not have a parent.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_node_parent = function (_id)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		return Nodes[# BBMOD_ESceneNode.Parent, _id & 0xFFFFFF];
	};

	/// @func add_child_node(_parent, _child)
	///
	/// @desc Adds a child node to given parent node.
	///
	/// @param {Real} _parent The ID of the parent node.
	/// @param {Real} _child The ID of the child node.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If the parent node or the child node does not
	/// exist.
	static add_child_node = function (_parent, _child)
	{
		gml_pragma("forceinline");
		if (!node_exists(_parent))
		{
			throw new BBMOD_Exception($"Invalid parent {_parent} - node does not exist!");
		}
		if (!node_exists(_parent))
		{
			throw new BBMOD_Exception($"Invalid child {_child} - node does not exist!");
		}
		Nodes[# BBMOD_ESceneNode.Parent, _child & 0xFFFFFF] = _parent;
		var _children = Nodes[# BBMOD_ESceneNode.Children, _parent & 0xFFFFFF];
		if (_children == undefined)
		{
			_children = [];
			Nodes[# BBMOD_ESceneNode.Children, _parent & 0xFFFFFF] = _children;
		}
		array_push(_children, _child);
		return self;
	};

	/// @func get_child_node_count(_id)
	///
	/// @desc Retrieves number of child nodes of a parent node with given ID.
	///
	/// @param {Real} _id The ID of the parent node.
	///
	/// @return {Real} The number of child nodes that the parent node has.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_child_node_count = function (_id)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _children = Nodes[# BBMOD_ESceneNode.Children, _id & 0xFFFFFF];
		if (_children == undefined)
		{
			return 0;
		}
		return array_length(_children);
	};

	/// @func get_child_node(_id, _index)
	///
	/// @desc Retrieves the ID of a child node at given index, of given parent
	/// node.
	///
	/// @param {Real} _id The ID of the parent node.
	/// @param {Real} _index The index of the child node. Must be greater than 0
	/// and less than the number of child nodes.
	///
	/// @return {Real} The ID of the child node at given index.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	/// @throws {BBMOD_OutOfRangeException} If given index is out of range of
	/// possible values.
	///
	/// @see BBMOD_Scene.get_child_node_count
	static get_child_node = function (_id, _index)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _children = Nodes[# BBMOD_ESceneNode.Children, _id & 0xFFFFFF];
		if (_children == undefined
			|| _index < 0
			|| _index >= array_length(_children))
		{
			throw new BBMOD_OutOfRangeException();
		}
		return _children[_index];
	};

	/// @func get_node_children(_id)
	///
	/// @desc Retrieves a read-only array with child node IDs of given parent
	/// node.
	///
	/// @param {Real} _id The ID of the parent node.
	///
	/// @return {Array<Real>} A read-only array with child node IDs.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist. 
	static get_node_children = function (_id)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		return Nodes[# BBMOD_ESceneNode.Children, _id & 0xFFFFFF] ?? [];
	};

	/// @func get_node_position(_id[, _dest])
	///
	/// @desc Retrieves the local-space position of a node with given ID.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {Struct.BBMOD_Vec3, Undefined} [_dest] A vector to store the
	/// position into. A new one is created if `undefined`.
	///
	/// @return {Struct.BBMOD_Vec3} The destination vector.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_node_position = function (_id, _dest=undefined)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		_dest ??= new BBMOD_Vec3();
		_dest.X = Nodes[# BBMOD_ESceneNode.PositionX, _index];
		_dest.Y = Nodes[# BBMOD_ESceneNode.PositionY, _index];
		_dest.Z = Nodes[# BBMOD_ESceneNode.PositionZ, _index];
		return _dest;
	};

	/// @func set_node_position(_id, _position)
	///
	/// @desc Changes the local-space position of a node with given ID.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {Struct.BBMOD_Vec3} _position The new position of the node.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static set_node_position = function (_id, _position)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		Nodes[# BBMOD_ESceneNode.PositionX, _index] = _position.X;
		Nodes[# BBMOD_ESceneNode.PositionY, _index] = _position.Y;
		Nodes[# BBMOD_ESceneNode.PositionZ, _index] = _position.Z;
		Nodes[# BBMOD_ESceneNode.Flags, _index] |= BBMOD_ESceneNodeFlags.IsTransformDirty;
		return self;
	};

	/// @func get_node_rotation(_id[, _dest])
	///
	/// @desc Retrieves the local-space rotation of a node with given ID.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {Struct.BBMOD_Quaternion, Undefined} [_dest] A quaternion to
    /// store the rotation into. A new one is created if `undefined`.
	///
	/// @return {Struct.BBMOD_Quaternion} The destination quaternion.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_node_rotation = function (_id, _dest=undefined)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		_dest ??= new BBMOD_Vec3();
		_dest.X = Nodes[# BBMOD_ESceneNode.RotationX, _index];
		_dest.Y = Nodes[# BBMOD_ESceneNode.RotationY, _index];
		_dest.Z = Nodes[# BBMOD_ESceneNode.RotationZ, _index];
		_dest.W = Nodes[# BBMOD_ESceneNode.RotationW, _index];
		return _dest;
	};

	/// @func set_node_rotation(_id, _rotation)
	///
	/// @desc Changes the local-space rotation of a node with given ID.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {Struct.BBMOD_Quaternion} _rotation The new rotation of the node.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static set_node_rotation = function (_id, _rotation)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		Nodes[# BBMOD_ESceneNode.RotationX, _index] = _rotation.X;
		Nodes[# BBMOD_ESceneNode.RotationY, _index] = _rotation.Y;
		Nodes[# BBMOD_ESceneNode.RotationZ, _index] = _rotation.Z;
		Nodes[# BBMOD_ESceneNode.RotationW, _index] = _rotation.W;
		Nodes[# BBMOD_ESceneNode.Flags, _index] |= BBMOD_ESceneNodeFlags.IsTransformDirty;
		return self;
	};

	/// @func get_node_scale(_id[, _dest])
	///
	/// @desc Retrieves the local-space scale of a node with given ID.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {Struct.BBMOD_Vec3, Undefined} [_dest] A vector to store the
	/// scale into. A new one is created if `undefined`.
	///
	/// @return {Struct.BBMOD_Vec3} The destination vector.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_node_scale = function (_id, _dest=undefined)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		_dest ??= new BBMOD_Vec3();
		_dest.X = Nodes[# BBMOD_ESceneNode.ScaleX, _index];
		_dest.Y = Nodes[# BBMOD_ESceneNode.ScaleY, _index];
		_dest.Z = Nodes[# BBMOD_ESceneNode.ScaleZ, _index];
		return _dest;
	};

	/// @func set_node_scale(_id, _scale)
	///
	/// @desc Changes the local-space scale of a node with given ID.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {Struct.BBMOD_Vec3} _scale The new scale of the node.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static set_node_scale = function (_id, _scale)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		Nodes[# BBMOD_ESceneNode.ScaleX, _index] = _scale.X;
		Nodes[# BBMOD_ESceneNode.ScaleY, _index] = _scale.Y;
		Nodes[# BBMOD_ESceneNode.ScaleZ, _index] = _scale.Z;
		Nodes[# BBMOD_ESceneNode.Flags, _index] |= BBMOD_ESceneNodeFlags.IsTransformDirty;
		return self;
	};

	/// @func get_node_transform(_id)
	///
	/// @desc Retrieves a read-only local-space transformation matrix of a node
	/// with given ID.
	///
	/// @param {Real} _id The ID of the node.
	///
	/// @return {Struct.BBMOD_Matrix} The transformation matrix.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_node_transform = function (_id)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		if ((Nodes[# BBMOD_ESceneNode.Flags, _index] & BBMOD_ESceneNodeFlags.IsTransformDirty) != 0)
		{
			static _matPosition = matrix_build_identity();
			_matPosition[@ 12] = Nodes[# BBMOD_ESceneNode.PositionX, _index];
			_matPosition[@ 13] = Nodes[# BBMOD_ESceneNode.PositionY, _index];
			_matPosition[@ 14] = Nodes[# BBMOD_ESceneNode.PositionZ, _index];

			static _rotation = new BBMOD_Quaternion();
			_rotation.X = Nodes[# BBMOD_ESceneNode.RotationX, _index];
			_rotation.Y = Nodes[# BBMOD_ESceneNode.RotationY, _index];
			_rotation.Z = Nodes[# BBMOD_ESceneNode.RotationZ, _index];
			_rotation.W = Nodes[# BBMOD_ESceneNode.RotationW, _index];

			static _matRotation = matrix_build_identity();
			_rotation.ToMatrix(_matRotation);

			static _matScale = matrix_build_identity();
			_matScale[@ 0] = Nodes[# BBMOD_ESceneNode.ScaleX, _index];
			_matScale[@ 5] = Nodes[# BBMOD_ESceneNode.ScaleY, _index];
			_matScale[@ 10] = Nodes[# BBMOD_ESceneNode.ScaleZ, _index];

			var _transform = Nodes[# BBMOD_ESceneNode.Transform, _index];
			_transform.Raw = matrix_multiply(matrix_multiply(_matScale, _matRotation), _matPosition);
			Nodes[# BBMOD_ESceneNode.Flags, _index] ^= BBMOD_ESceneNodeFlags.IsTransformDirty;
			return _transform;
		}
		return Nodes[# BBMOD_ESceneNode.Transform, _index];
	};

	/// @func set_node_transform(_id, _transform)
	///
	/// @desc Changes the local-space transformation matrix of a node with given
	/// ID.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {Struct.BBMOD_Matrix} _transform The new local-space
	/// transformation of the node.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static set_node_transform = function (_id, _transform)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		_transform.Copy(Nodes[# BBMOD_ESceneNode.Transform, _index]);
		// TODO: Decompose local-space transform into position, rotation and scale
		Nodes[# BBMOD_ESceneNode.Flags, _index] ^= BBMOD_ESceneNodeFlags.IsTransformDirty;
		return self;
	};

	/// @func get_node_transform_absolute(_id)
	///
	/// @desc Retrieves a read-only global-space transformation matrix of a node
	/// with given ID.
	///
	/// @param {Real} _id The ID of the node.
	///
	/// @return {Struct.BBMOD_Matrix} The transformation matrix.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	///
	/// @note This should be called after {@link BBMOD_Scene.update}, otherwise
	/// the transformation matrix might not be up to date!
	static get_node_transform_absolute = function (_id)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		return Nodes[# BBMOD_ESceneNode.TransfromAbsolute, _index];
	};

	/// @func set_node_transform_absolute(_id, _transform)
	///
	/// @desc Changes the global-space transformation matrix of a node with
	/// given ID.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {Struct.BBMOD_Matrix} _transform The new global-space
	/// transformation of the node.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static set_node_transform_absolute = function (_id, _transform)
	{
		// TODO: Implement set_node_transform_absolute
		return self;
	};

	/// @func get_node_model_path(_id)
	///
	/// @desc Retrieves path to a model that a node with given ID draws.
	///
	/// @param {Real} _id The ID of the node.
	///
	/// @return {String, Undefined} The path to the model or `undefined` if
	/// given node does not have any.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_node_model_path = function (_id)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		return Nodes[# BBMOD_ESceneNode.Model, _index & 0xFFFFFF];
	};

	/// @func set_node_model_path(_id, _path)
	///
	/// @desc Changes path to a model that a node with given ID draws.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {String, Undefined} _path The path to a new model or `undefined`,
	/// in which case the current model is removed from the node.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static set_node_model_path = function (_id, _path)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _model = Nodes[# BBMOD_ESceneNode.Model, _index & 0xFFFFFF];
		if (_model != undefined && ResourceManager.has(_model))
		{
			ResourceManager.free(_model);
		}
		Nodes[# BBMOD_ESceneNode.Model, _index & 0xFFFFFF] = _path;
		return self;
	};

	/// @func get_node_model(_id)
	///
	/// @desc Retrieves a model that a node with given ID draws.
	///
	/// @param {Real} _id The ID of the node.
	///
	/// @return {Struct.BBMOD_Model} The model.
	///
	/// @note The model might not be loaded yet! Use {@ BBMOD_Resource.IsLoaded}
	/// to check if it is before using any of its properties!
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_node_model = function (_id)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		var _modelPath = Nodes[# BBMOD_ESceneNode.Model, _index];
		return ResourceManager.load(_modelPath, function (_error, _model) {
			if (_model != undefined)
			{
				_model.freeze();
			}
		});
	};

	/// @func get_node_material(_id, _index)
	///
	/// @desc Retrieves a material at a specified index that a node with given
	/// ID uses to override a material defined in its model.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {Real} _index The index of the material.
	///
	/// @return {Struct.BBMOD_Material, Undefined} The material or `undefined`
	/// if the node does not have a material specified for given index.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_node_material = function (_id, _index)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _nodeIndex = _id & 0xFFFFFF;
		var _materials = Nodes[# BBMOD_ESceneNode.Model, _nodeIndex];
		if (_materials == undefined
			|| _index < 0
			|| _index >= array_length(_materials))
		{
			return undefined;
		}
		return _materials[_index];
	};

	/// @func set_node_material(_id, _index, _material)
	///
	/// @desc Changes a material at a specified index that a node with given ID
	/// uses to override a material defined in its model.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {Real} _index The index of the material.
	/// @param {Struct.BBMOD_Model, Undefined} _material The new material or
	/// `undefined` to remove the current one.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	///
	/// @note The material is automatically destroyed when no longer needed!
	static set_node_material = function (_id, _index, _material)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _nodeIndex = _id & 0xFFFFFF;
		var _materials = Nodes[# BBMOD_ESceneNode.Materials, _nodeIndex];
		if (_materials == undefined)
		{
			_materials = array_create(_index + 1);
			Nodes[# BBMOD_ESceneNode.Materials, _nodeIndex] = _materials;
		}
		else if (array_length(_materials) < _index + 1)
		{
			array_resize(_materials, _index + 1);
		}
		var _materialOld = _materials[_index];
		if (_materialOld != undefined)
		{
			_materialOld.free();
		}
		// TODO: Add material to ResourceManager
		_materials[@ _index] = _material.ref();
		return self;
	};

	/// @func get_node_material_props(_id)
	///
	/// @desc Retrieves a material property block associated with a node with
	/// given ID.
	///
	/// @param {Real} _id The ID of the node.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock, Undefined} The material
	/// property block associated with the node or `undefined` if the node has
	/// none.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_node_material_props = function (_id)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		return Nodes[# BBMOD_ESceneNode.MaterialProps, _id & 0xFFFFFF];
	};

	/// @func set_node_material_props(_id, _props)
	///
	/// @desc Changes a material property block associated with a node with
	/// given ID.
	///
	/// @param {Real} _id The ID of the node.
	/// @param {Struct.BBMOD_MaterialPropertyBlock, Undefined} _props The new
	/// material property block or `undefined` to remove the current one.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static set_node_material_props = function (_id, _props)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		Nodes[# BBMOD_ESceneNode.MaterialProps, _id & 0xFFFFFF] = _props;
		return self;
	};

	/// @func get_node_animation_player(_id)
	///
	/// @desc Retrieves an animation player of a node with given ID, if it has
	/// one.
	///
	/// @param {Real} _id The ID of the node.
	///
	/// @return {Struct.BBMOD_AnimationPlayer, Undefined} The animation player
	/// or `undefined` if given node does not have one.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static get_node_animation_player = function (_id)
	{
		gml_pragma("forceinline");
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		var _animationPlayer = Nodes[# BBMOD_ESceneNode.AnimationPlayer, _index];
		if (_animationPlayer == undefined)
		{
			var _animationPath = Nodes[# BBMOD_ESceneNode.Animation, _index];
			if (_animationPath != undefined)
			{
				var _animation = ResourceManager.load(_animationPath);
				var _loop = (Nodes[# BBMOD_ESceneNode.Flags, _index] & BBMOD_ESceneNodeFlags.IsAnimationLooping) != 0;
				_animationPlayer = new BBMOD_AnimationPlayer(get_node_model(_id));
				_animationPlayer.play(_animation, _loop);
				Nodes[# BBMOD_ESceneNode.AnimationPlayer, _index] = _animationPlayer;
			}
		}
		return _animationPlayer;
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

	/// @func add_camera(_camera)
	///
	/// @desc Adds a camera to the scene.
	///
	/// @param {Struct.BBMOD_BaseCamera} _camera The camera to add.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static add_camera = function (_camera)
	{
		gml_pragma("forceinline");
		array_push(Cameras, _camera);
		return self;
	};

	/// @func get_camera_count()
	///
	/// @desc Retrieves number of cameras added to the scene.
	///
	/// @return {Real} The number of cameras added to the scene.
	static get_camera_count = function ()
	{
		gml_pragma("forceinline");
		return array_length(Cameras);
	};

	/// @func get_camera(_index)
	///
	/// @desc Retrieves a camera at given index.
	///
	/// @param {Real} _index The index of the camera.
	///
	/// @return {Struct.BBMOD_BaseCamera} The camera at given
	/// index.
	static get_camera = function (_index)
	{
		gml_pragma("forceinline");
		return Cameras[_index];
	};

	/// @func remove_camera(_camera)
	///
	/// @desc Removes a camera at given index from the scene.
	///
	/// @param {Struct.BBMOD_BaseCamera} _camera The camera to remove.
	///
	/// @return {Bool} Returns `true` if the camera was removed of `false` if
	/// the camera was not found in the scene.
	static remove_camera = function (_camera)
	{
		gml_pragma("forceinline");
		var _cameras = Cameras;
		var i = 0;
		repeat (array_length(_cameras))
		{
			if (_cameras[i] == _camera)
			{
				array_delete(_cameras, i, 1);
				return true;
			}
			++i;
		}
		return false;
	};

	/// @func remove_camera_index(_index)
	///
	/// @desc Removes a camera at given index from the scene.
	///
	/// @param {Real} _index The index to remove the camera at.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static remove_camera_index = function (_index)
	{
		gml_pragma("forceinline");
		array_delete(Cameras, _index, 1);
		return self;
	};

	/// @func clear_cameras()
	///
	/// @desc Removes all cameras added to the scene.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	static clear_cameras = function ()
	{
		gml_pragma("forceinline");
		Cameras = [];
		return self;
	};

	/// @func update_node_transform_chain(_id)
	///
	/// @desc Recursively updates node transformation matrices, starting at the
	/// node with given ID, then its children, grandchildren etc.
	///
	/// @param {Real} _id The ID of of the node to start updating transforms
	/// from.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If a node with given ID does not exist.
	static update_node_transform_chain = function (_id)
	{
		__BBMOD_CHECK_SCENE_NODE_EXISTS;
		var _index = _id & 0xFFFFFF;
		var _transform = get_node_transform(_id);
		var _children = Nodes[# BBMOD_ESceneNode.Children, _index];
		if (_children != undefined)
		{
			var i = 0;
			repeat (array_length(_children))
			{
				var _child = _children[i++];
				var _childTransform = get_node_transform(_child);
				Nodes[# BBMOD_ESceneNode.TransfromAbsolute, _child & 0xFFFFFF].Raw =
					matrix_multiply(_childTransform.Raw, _transform.Raw);
				update_node_transform_chain(_child);
			}
		}
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
	///
	/// @note Order in which are nodes updated is not defined!
	static update = function (_deltaTime)
	{
		global.__bbmodSceneCurrent = self;

		if (CameraCurrent != undefined)
		{
			CameraCurrent.update(delta_time);
		}

		var _index = 0;
		repeat (__nodeIndexNext)
		{
			var _id = (Nodes[# BBMOD_ESceneNode.Generation, _index] << 24) | _index;
			if ((Nodes[# BBMOD_ESceneNode.Flags, _index] & BBMOD_ESceneNodeFlags.IsAlive) != 0)
			{
				if (!node_exists(Nodes[# BBMOD_ESceneNode.Parent, _index]))
				{
					update_node_transform_chain(_id);
					array_copy(
						Nodes[# BBMOD_ESceneNode.TransfromAbsolute, _index].Raw, 0,
						Nodes[# BBMOD_ESceneNode.Transform, _index].Raw, 0, 16);
				}
				var _animationPlayer = get_node_animation_player(_id);
				if (_animationPlayer != undefined)
				{
					_animationPlayer.update(_deltaTime);
				}
			}
			++_index;
		}

		return self;
	};

	/// @func submit()
	///
	/// @desc Immediately submits the whole scene for rendering.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @note Order in which are nodes submitted is not defined!
	static submit = function ()
	{
		global.__bbmodSceneCurrent = self;

		if (CameraCurrent != undefined)
		{
			CameraCurrent.apply();
		}

		if (Terrain != undefined)
		{
			Terrain.submit();
		}

		var _index = 0;
		repeat (__nodeIndexNext)
		{
			var _id = (Nodes[# BBMOD_ESceneNode.Generation, _index] << 24) | _index;
			if ((Nodes[# BBMOD_ESceneNode.Flags, _index] & BBMOD_ESceneNodeFlags.IsAlive) != 0)
			{
				var _animationPlayer = get_node_animation_player(_id);
				if (_animationPlayer != undefined)
				{
					matrix_set(matrix_world, get_node_transform_absolute(_id).Raw);
					bbmod_material_props_set(get_node_material_props(_id));
					var _materials = Nodes[# BBMOD_ESceneNode.Materials, _index];
					_animationPlayer.submit(_materials);
				}
				else
				{
					var _model = get_node_model(_id);
					if (_model != undefined)
					{
						matrix_set(matrix_world, get_node_transform_absolute(_id).Raw);
						bbmod_material_props_set(get_node_material_props(_id));
						var _materials = Nodes[# BBMOD_ESceneNode.Materials, _index];
						_model.submit(_materials);
					}
				}
			}
			++_index;
		}
		matrix_set(matrix_world, matrix_build_identity());
		bbmod_material_reset();

		return self;
	};

	/// @func render()
	///
	/// @desc Enqueues the whole scene for rendering.
	///
	/// @return {Struct.BBMOD_Scene} Returns `self`.
	///
	/// @note Order in which are nodes rendered is not defined!
	static render = function ()
	{
		global.__bbmodSceneCurrent = self;

		if (CameraCurrent != undefined)
		{
			CameraCurrent.apply();
		}

		if (Terrain != undefined)
		{
			Terrain.render();
		}

		var _index = 0;
		repeat (__nodeIndexNext)
		{
			var _id = (Nodes[# BBMOD_ESceneNode.Generation, _index] << 24) | _index;
			if ((Nodes[# BBMOD_ESceneNode.Flags, _index] & BBMOD_ESceneNodeFlags.IsAlive) != 0)
			{
				var _animationPlayer = get_node_animation_player(_id);
				if (_animationPlayer != undefined)
				{
					matrix_set(matrix_world, get_node_transform_absolute(_id).Raw);
					bbmod_material_props_set(get_node_material_props(_id));
					var _materials = Nodes[# BBMOD_ESceneNode.Materials, _index];
					_animationPlayer.render(_materials);
				}
				else
				{
					var _model = get_node_model(_id);
					if (_model != undefined)
					{
						matrix_set(matrix_world, get_node_transform_absolute(_id).Raw);
						bbmod_material_props_set(get_node_material_props(_id));
						var _materials = Nodes[# BBMOD_ESceneNode.Materials, _index];
						_model.render(_materials);
					}
				}
			}
			++_index;
		}
		matrix_set(matrix_world, matrix_build_identity());

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
		clear_nodes();

		if (Terrain != undefined)
		{
			Terrain = Terrain.destroy();
		}

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

		for (var i = array_length(Cameras) - 1; i >= 0; --i)
		{
			Cameras[i].destroy();
		}
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
