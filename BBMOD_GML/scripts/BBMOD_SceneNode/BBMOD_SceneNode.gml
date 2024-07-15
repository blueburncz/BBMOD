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
	/// before using,
	/// @private
	__transformDirty = true;

	/// @var {Bool} Whether the node's position, rotation and scale is final and
	/// renders only non-animated models. Defaults to `false`.
	IsStatic = false;

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

	/// @func update(_deltaTime)
	///
	/// @desc Updates the node.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_SceneNode} Returns `self`.
	static update = function (_deltaTime)
	{
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			Children[i].update(_deltaTime);
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
