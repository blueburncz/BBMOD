/// @module Core

/// @enum Enumeration of scene node kinds.
enum BBMOD_ESceneNodeType
{
	/// @member Unknown or disabled scene node kind.
	None,
	/// @member Camera scene node.
	Camera,
	/// @member Model scene node.
	Model,
	/// @member Model hierarchy node.
	ModelNode,
	/// @member Point light scene node.
	PointLight,
	/// @member Spot light scene node.
	SpotLight,
	/// @member Directional light scene node.
	DirectionalLight,
	/// @member Reflection probe scene node.
	ReflectionProbe,
	/// @member Particle emitter scene node.
	ParticleEmitter,
	/// @member Terrain scene node.
	Terrain,
	/// @member Lens flare scene node.
	LensFlare,
	/// @member Custom scene node.
	Custom,
}

/// @enum Bit flags for editable scene nodes.
enum BBMOD_EEditorFlag
{
	/// @member The node can be translated.
	Translate = 0x1,
		/// @member The node can be rotated.
		Rotate = 0x2,
		/// @member The node can be scaled.
		Scale = 0x4,
		/// @member Editing the node updates captured reflection probes.
		RefreshReflectionProbes = 0x8,
}

/// @func BBMOD_SceneNode([_kind[, _flags]])
///
/// @desc Base constructor for runtime objects that can belong to a
/// {@link BBMOD_Scene}, participate in a parent-child hierarchy, and be edited
/// through editor icons.
///
/// @param {Real} [_kind] The scene node kind. Defaults to
/// {@link BBMOD_ESceneNodeType.None}.
/// @param {Real} [_flags] The editor target capability flags. Defaults to 0.
function BBMOD_SceneNode(
	_kind = BBMOD_ESceneNodeType.None,
	_flags = 0
) constructor
{
	/// @var {Struct.BBMOD_Scene, Undefined} The scene this node belongs to.
	/// @readonly
	Scene = undefined;

	/// @var {Struct.BBMOD_SceneNode, Undefined} The parent scene node.
	/// @readonly
	Parent = undefined;

	/// @var {Array<Struct.BBMOD_SceneNode>} Child scene nodes.
	/// @readonly
	Children = [];

	/// @var {Real} Scene node kind. Uses {@link BBMOD_ESceneNodeType}.
	SceneNodeKind = _kind;

	/// @var {Struct.BBMOD_Vec3} Local position relative to the parent.
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} Local rotation relative to the parent.
	Rotation = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} Local scale relative to the parent.
	Scale = new BBMOD_Vec3(1.0);

	/// @var {Bool} Whether the cached world transform is dirty.
	TransformDirty = true;

	/// @var {Real} Editor-selectable flags. Uses {@link BBMOD_EEditorFlag}.
	EditorFlags = _flags;

	/// @var {Asset.GMSprite} Sprite used for the editor icon.
	EditorIconSprite = BBMOD_SprParticle;

	/// @var {Real} Subimage used for the editor icon.
	EditorIconIndex = 0;

	/// @var {Real} Click priority when editor icons overlap.
	EditorPickPriority = 0;

	/// @var {Real} Distance at which the editor icon starts fading out. Use
	/// `infinity` to disable fading. Defaults to 100.0.
	EditorIconFadeStart = 100.0;

	/// @var {Real} Distance at which the editor icon becomes hidden. Use
	/// `infinity` to disable fading. Defaults to 120.0.
	EditorIconFadeEnd = 120.0;

	/// @var {Struct.BBMOD_Vec3} Editor icon world-space offset.
	EditorOffset = new BBMOD_Vec3();

	/// @var {Array<Real>} Cached local matrix.
	/// @private
	__localMatrix = matrix_build_identity();

	/// @var {Array<Real>} Cached world matrix.
	/// @private
	__worldMatrix = matrix_build_identity();

	/// @func add_child(_node)
	///
	/// @desc Adds a child node.
	///
	/// @param {Struct.BBMOD_SceneNode} _node The child node to add.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static add_child = function (_node)
	{
		if (_node.Parent == self)
		{
			return self;
		}

		if (_node.Parent != undefined)
		{
			_node.Parent.remove_child(_node);
		}
		else if (_node.Scene != undefined && _node.Scene != Scene)
		{
			_node.Scene.remove_node(_node);
		}

		array_push(Children, _node);
		_node.Parent = self;
		_node.mark_transform_dirty();

		if (Scene != undefined)
		{
			Scene.add_node(_node);
		}

		return self;
	};

	/// @func remove_child(_node)
	///
	/// @desc Removes a child node from this node.
	///
	/// @param {Struct.BBMOD_SceneNode} _node The child node to remove.
	///
	/// @return {Bool} Returns `true` if the child was removed.
	static remove_child = function (_node)
	{
		var i = 0;
		repeat(array_length(Children))
		{
			if (Children[i] == _node)
			{
				array_delete(Children, i, 1);
				_node.Parent = undefined;
				_node.mark_transform_dirty();

				if (Scene != undefined && _node.Scene == Scene)
				{
					Scene.__add_root_node(_node);
				}

				return true;
			}
			++i;
		}
		return false;
	};

	/// @func remove_from_parent()
	///
	/// @desc Removes this node from its parent.
	///
	/// @return {Bool} Returns `true` if the node had a parent.
	static remove_from_parent = function ()
	{
		if (Parent == undefined)
		{
			return false;
		}
		return Parent.remove_child(self);
	};

	/// @func set_position(_position)
	///
	/// @desc Sets the local position.
	///
	/// @param {Struct.BBMOD_Vec3} _position The new local position.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static set_position = function (_position)
	{
		if (!Position.Equals(_position))
		{
			Position = _position;
			mark_transform_dirty();
		}
		return self;
	};

	/// @func set_rotation(_rotation)
	///
	/// @desc Sets the local rotation.
	///
	/// @param {Struct.BBMOD_Vec3} _rotation The new local rotation.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static set_rotation = function (_rotation)
	{
		if (!Rotation.Equals(_rotation))
		{
			Rotation = _rotation;
			mark_transform_dirty();
		}
		return self;
	};

	/// @func set_scale(_scale)
	///
	/// @desc Sets the local scale.
	///
	/// @param {Struct.BBMOD_Vec3} _scale The new local scale.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static set_scale = function (_scale)
	{
		if (!Scale.Equals(_scale))
		{
			Scale = _scale;
			mark_transform_dirty();
		}
		return self;
	};

	/// @func mark_transform_dirty()
	///
	/// @desc Marks this node and its descendants as needing world transform
	/// recalculation.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static mark_transform_dirty = function ()
	{
		TransformDirty = true;

		var i = 0;
		repeat(array_length(Children))
		{
			Children[i++].mark_transform_dirty();
		}

		return self;
	};

	/// @func get_local_matrix()
	///
	/// @desc Retrieves the node local transform matrix.
	///
	/// @return {Array<Real>} The local transform matrix.
	static get_local_matrix = function ()
	{
		__localMatrix = matrix_build(
			Position.X,
			Position.Y,
			Position.Z,
			Rotation.X,
			Rotation.Y,
			Rotation.Z,
			Scale.X,
			Scale.Y,
			Scale.Z);
		return __localMatrix;
	};

	/// @func get_world_matrix()
	///
	/// @desc Retrieves the node world transform matrix.
	///
	/// @return {Array<Real>} The world transform matrix.
	static get_world_matrix = function ()
	{
		if (TransformDirty)
		{
			if (Parent == undefined)
			{
				__worldMatrix = get_local_matrix();
			}
			else
			{
				__worldMatrix = matrix_multiply(get_local_matrix(), Parent.get_world_matrix());
			}

			TransformDirty = false;
		}

		return __worldMatrix;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Updates the scene node.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static update = function (_deltaTime)
	{
		return self;
	};

	/// @func destroy()
	///
	/// @desc Destroys the scene node and all child nodes.
	///
	/// @return {Undefined} Returns `undefined`.
	static destroy = function ()
	{
		if (Scene != undefined)
		{
			Scene.remove_node(self);
		}

		var i = array_length(Children) - 1;
		repeat(array_length(Children))
		{
			Children[i].destroy();
			--i;
		}

		Children = undefined;
		Parent = undefined;
		return undefined;
	};
}
