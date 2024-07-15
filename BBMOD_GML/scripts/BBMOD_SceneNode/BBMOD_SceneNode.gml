/// @module Core

/// @func BBMOD_SceneNode([_name])
///
/// @implements {BBMOD_IDestructible}
///
/// @desc The base struct for all nodes that can be added to a scene.
///
/// @param {String, Undefined} [_name] The name of the node or `undefined`, in
/// which case it is generated.
///
/// @see BBMOD_Scene
function BBMOD_SceneNode(_name=undefined) constructor
{
	static __nodeCounter = 0;

	/// @var {String} The name of the node.
	Name = _name ?? $"Node{__nodeCounter++}";

	/// @var {Struct.BBMOD_Scene, Undefined} The scene to which the node
	/// belongs. Defaults to `undefiend`.
	/// @private
	__scene = undefined;

	/// @var {Struct.BBMOD_SceneNode, Undefined} The parent of the node.
	/// Defaults to `undefined`.
	/// @readonly
	Parent = undefined;

	/// @var {Array<Struct.BBMOD_SceneNode>} An array of child nodes.
	/// @readonly
	Children = [];

	/// @var {Struct.BBMOD_Vec3} The position of the node, relative to its
	/// parent.
	/// @readonly
	/// @see BBMOD_SceneNode.set_position
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The rotation of the node, relative to its
	/// parent.
	/// @readonly
	/// @see BBMOD_SceneNode.set_rotation
	Rotation = new BBMOD_Quaternion();

	/// @var {Struct.BBMOD_Vec3} The scale of the node, relative to its
	/// parent.
	/// @readonly
	/// @see BBMOD_SceneNode.set_scale
	Scale = new BBMOD_Vec3(1.0);

	/// @var {Struct.BBMOD_Matrix} The transform matrix of the node, relative to
	/// its parent.
	/// @private
	__transform = new BBMOD_Matrix();

	/// @var {Bool} If `true` then the transform matrix needs to be updated
	/// before using.
	/// @private
	__transformDirty = true;

	/// @var {Struct.BBMOD_Matrix} The absolute transform matrix of the node.
	/// @private
	__transformAbsolute = new BBMOD_Matrix();

	/// @var {Bool} If `true` then the absolute transform matrix needs to be
	/// updated before using.
	/// @private
	__transformAbsoluteDirty = true;

	/// @var {Bool} Whether the node's position, rotation and scale is final and
	/// renders only non-animated models. Defaults to `false`.
	IsStatic = false;

	/// @func set_position(_position)
	///
	/// @desc Changes the node's position relative to its parent.
	///
	/// @param {Struct.BBMOD_Vec3} _position The new position of the node.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static set_position = function (_position)
	{
		gml_pragma("forceinline");
		if (!_position.Equals(Position))
		{
			_position.Copy(Position);
			__transformDirty = true;
		}
		return self;
	};

	/// @func set_rotation(_rotation)
	///
	/// @desc Changes the node's rotation relative to its parent.
	///
	/// @param {Struct.BBMOD_Quaternion} _rotation The new rotation of the node.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static set_rotation = function (_rotation)
	{
		gml_pragma("forceinline");
		if (!_rotation.Equals(Rotation))
		{
			_rotation.Copy(Rotation);
			__transformDirty = true;
		}
		return self;
	};

	/// @func set_scale(_scale)
	///
	/// @desc Changes the node's scale relative to its parent.
	///
	/// @param {Struct.BBMOD_Vec3} _scale The new scale of the node.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static set_scale = function (_scale)
	{
		gml_pragma("forceinline");
		if (!_scale.Equals(Scale))
		{
			_scale.Copy(Scale);
			__transformDirty = true;
		}
		return self;
	};

	/// @func get_transform()
	///
	/// @desc Retrieves a read-only transformation matrix of the node, relative to
	/// its parent. The order of transforms in the matrix is scale, rotate, translate.
	///
	/// @return {Struct.BBMOD_Matrix} The read-only transformation matrix of the
	/// node, relative to its parent.
	static get_transform = function ()
	{
		if (__transformDirty)
		{
			var _matPos = matrix_build_identity();
			_matPos[@ 12] = Position.X;
			_matPos[@ 13] = Position.Y;
			_matPos[@ 14] = Position.Z;

			var _matRot = matrix_build_identity();
			Rotation.ToMatrix(_matRot);

			var _matScale = matrix_build_identity();
			_matScale[@ 0] = Scale.X;
			_matScale[@ 5] = Scale.Y;
			_matScale[@ 10] = Scale.Z;

			__transform.Raw = matrix_multiply(matrix_multiply(_matScale, _matRot), _matPos);

			__transformDirty = false;
		}
		return __transform;
	};

	/// @func __mark_absolute_transform_dirty()
	///
	/// @desc Recursively marks absolute transform as dirty.
	///
	/// @private
	static __mark_absolute_transform_dirty = function ()
	{
		__transformAbsoluteDirty = true;
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			Children[i].__mark_absolute_transform_dirty();
		}
	};

	/// @func get_transform_absolute()
	///
	/// @desc Retrieves a read-only absolute transformation matrix of the node.
	/// The order of transforms in the matrix is scale, rotate, translate.
	///
	/// @return {Struct.BBMOD_Matrix} The read-only absolute transformation
	/// matrix of the node.
	static get_transform_absolute = function ()
	{
		if (__transformAbsoluteDirty)
		{
			if (Parent != undefined)
			{
				__transformAbsolute.Raw = matrix_multiply(Parent.get_transform_absolute().Raw, get_transform().Raw);
			}
			else
			{
				array_copy(__transformAbsolute.Raw, 0, get_transform().Raw, 0, 16);
			}
			__transformAbsoluteDirty = false;
		}
		return __transformAbsolute;
	};

	/// @func is_root()
	///
	/// @desc Returns whether the node is a root node, i.e. it does not have a
	/// parent.
	///
	/// @return {Bool} Returns `true` if the node does not have a parent.
	static is_root = function ()
	{
		gml_pragma("forceinline");
		return (Parent == undefined);
	};

	/// @func is_leaf()
	///
	/// @desc Returns whether the node is a leaf node, i.e. it does not have
	/// child nodes.
	///
	/// @return {Bool} Returns `true` if the node does not have child nodes.
	static is_leaf = function ()
	{
		gml_pragma("forceinline");
		return (array_length(Children) == 0);
	};

	/// @func __unset_scene()
	///
	/// @desc Recursively sets scene to `undefiend`.
	///
	/// @private
	static __unset_scene = function ()
	{
		__scene = undefined;
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			Children[i].__unset_scene();
		}
	};

	/// @func get_scene()
	///
	/// @desc Retrieves the scene to which the node belongs.
	///
	/// @return {Struct.BBMOD_Scene, Undefined} The scene to which the node
	/// belongs or `undefined`.
	static get_scene = function ()
	{
		var _currentNode = self;
		while (_currentNode != undefined)
		{
			if (_currentNode.__scene != undefined)
			{
				__scene = _currentNode.__scene;
				break;
			}
			_currentNode = _currentNode.Parent;
		}
		return __scene;
	};

	/// @func add_child(_node)
	///
	/// @desc Adds a child node.
	///
	/// @param {Struct.BBMOD_SceneNode} _node The child node to add.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static add_child = function (_node)
	{
		bbmod_assert(_node.Parent == undefined, "Node already has a parent!");
		array_push(Children, _node);
		_node.Parent = self;
		_node.__scene = __scene;
		_node.__mark_absolute_transform_dirty();
		return self;
	};

	/// @func remove_child(_node)
	///
	/// @desc Removes a child node.
	///
	/// @param {Struct.BBMOD_SceneNode} _node The child node to remove.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static remove_child = function (_node)
	{
		bbmod_assert(_node.Parent == self, "Not a child of this node!");
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			if (Children[i] == _node)
			{
				array_delete(Children, i, 1);
				_node.Parent = undefined;
				_node.__unset_scene();
				_node.__mark_absolute_transform_dirty();
				break;
			}
		}
		return self;
	};

	/// @func clear_children()
	///
	/// @desc Removes all child nodes.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static clear_children = function ()
	{
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			with (Children[i])
			{
				Parent = undefined;
				__unset_scene();
				__mark_absolute_transform_dirty();
			}
		}
		Children = [];
		return self;
	};

	/// @func remove_self()
	///
	/// @desc Removes the node from its parent, if it has any.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static remove_self = function ()
	{
		gml_pragma("forceinline");
		if (Parent != undefined)
		{
			Parent.remove_child(self);
		}
		return self;
	};

	/// @func find_node(_name)
	///
	/// @desc Tries to find a node by its name.
	///
	/// @param {String} _name The name of the node to find.
	///
	/// @return {Struct.BBMOD_SceneNode, Undefined} Returns the found node or
	/// `undefined`.
	static find_node = function (_name)
	{
		if (Name == _name)
		{
			return self;
		}
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			var _found = Children[i].find_node(_name);
			if (_found != undefined)
			{
				return _found;
			}
		}
		return undefined;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Updates the node.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	///
	/// @note The transformation matrices of the node are updated during this
	/// function. If you would like to change its position, rotation or scale,
	/// you should do it **before** this function is called!
	static update = function (_deltaTime)
	{
		var _transform = get_transform_absolute().Raw;
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			with (Children[i])
			{
				__transformAbsolute = matrix_multiply(_transform, get_transform().Raw);
				__transformAbsoluteDirty = false;
				update(_deltaTime);
			}
		}
		return self;
	};

	/// @func submit()
	///
	/// @desc Immediately submits the node and its child nodes recursively for
	/// rendering.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static submit = function ()
	{
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			Children[i].submit();
		}
		return self;
	};

	/// @func render()
	///
	/// @desc Enqueues the node and its child nodes recursively for rendering.
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static render = function ()
	{
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			Children[i].render();
		}
		return self;
	};

	static destroy = function ()
	{
		remove_self();
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			with (Children[i])
			{
				Parent = undefined; // To skip remove_self
				destroy();
			}
		}
		Children = undefined;
		return undefined;
	};
}
