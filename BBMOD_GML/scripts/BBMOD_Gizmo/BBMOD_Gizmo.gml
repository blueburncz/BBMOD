/// @module Gizmo

/// @enum Enumeration of edit spaces.
enum BBMOD_EEditSpace
{
	/// @member Edit instances in world-space.
	Global,
	/// @member Edit instance relatively to its transformation.
	Local,
	/// @member Total number of members of this enum.
	SIZE,
};

/// @enum Enumeration of edit types.
enum BBMOD_EEditType
{
	/// @member Translate selected instances.
	Position,
	/// @member Rotate selected instances.
	Rotation,
	/// @member Scale selected instances.
	Scale,
	/// @member Total number of members of this enum.
	SIZE,
};

/// @enum Enumeration of edit axes.
enum BBMOD_EEditAxis
{
	/// @member No edit.
	None = 0,
		/// @member Edit on X axis.
		X = $1,
		/// @member Edit on Y axis.
		Y = $10,
		/// @member Edit on Z axis.
		Z = $100,
		/// @member Edit on all axes.
		All = $111,
};

/// @func BBMOD_Gizmo([_size])
///
/// @implements {BBMOD_IDestructible}
///
/// @desc A gizmo for transforming instances.
///
/// @param {Real} [_size] The size of the gizmo. Default value is 10 units.
///
/// @note This requires synchronous loading of models, therefore it cannot
/// be used on platforms like HTML5, which require asynchronous loading.
/// You also **must** use {@link BBMOD_Camera} for the gizmo to work properly!
function BBMOD_Gizmo(_size = 10.0) constructor
{
	/// @var {Array<Struct.BBMOD_Model>} Gizmo models for individual edit modes.
	/// @note Please note that these are not loaded asynchronously, therefore
	/// the gizmo cannot be used on platforms that require asynchronous loading,
	/// like HTML5!
	/// @see BBMOD_EEditType
	/// @readonly
	static Models = undefined;

	/// @var {Array<Struct.BBMOD_Material>} Materials used when mouse-picking
	/// the gizmo.
	static MaterialsSelect = undefined;

	if (Models == undefined)
	{
		var _shaderSelect = new BBMOD_BaseShader(
			BBMOD_ShGizmoSelect, BBMOD_VFORMAT_DEFAULT);
		var _materialSelect = new BBMOD_BaseMaterial(_shaderSelect);
		_materialSelect.BaseOpacity = sprite_get_texture(BBMOD_SprGizmo, 1);
		MaterialsSelect = [_materialSelect];

		var _shader = new BBMOD_DefaultShader(BBMOD_ShGizmo, BBMOD_VFORMAT_DEFAULT);
		var _material = new BBMOD_DefaultMaterial(_shader);
		_material.BaseOpacity = sprite_get_texture(BBMOD_SprGizmo, 0);

		var _modelMove = new BBMOD_Model("Data/BBMOD/Models/GizmoMove.bbmod")
			.freeze();
		// TODO: Fix gizmo model
		_modelMove.RootNode.Transform = new BBMOD_DualQuaternion();
		_modelMove.Materials[@ 0] = _material;

		var _modelScale = new BBMOD_Model("Data/BBMOD/Models/GizmoScale.bbmod")
			.freeze();
		_modelScale.Materials[@ 0] = _material;

		var _modelRotate = new BBMOD_Model("Data/BBMOD/Models/GizmoRotate.bbmod")
			.freeze();
		_modelRotate.Materials[@ 0] = _material;

		Models = [
			_modelMove,
			_modelRotate,
			_modelScale,
		];
	}

	/// @var {Bool} If `true` then the gizmo is editing selected instances.
	IsEditing = false;

	/// @var {Struct.BBMOD_Vec2} Screen-space coordinates to lock the mouse
	/// cursor at or `undefined`.
	/// @private
	__mouseLockAt = undefined;

	/// @var {Struct.BBMOD_Vec3} World-space offset from the mouse to the gizmo
	/// or `undefined`.
	/// @private
	__mouseOffset = undefined;

	/// @var {Constant.Cursor} The cursor used before editing started.
	/// @private
	__cursorBackup = undefined;

	/// @var {Bool} Enables snapping to grid when moving objects. Default value
	/// is `true`.
	/// @see BBMOD_Gizmo.GridSize
	EnableGridSnap = true;

	/// @var {Struct.BBMOD_Vec3} The size of the grid. Default value is
	/// `(1, 1, 1)`.
	/// @see BBMOD_Gizmo.EnableGridSnap
	GridSize = new BBMOD_Vec3(1.0);

	/// @var {Bool} Enables angle snapping when rotating objects. Default value
	/// is `true`.
	/// @see BBMOD_Gizmo.AngleSnap
	EnableAngleSnap = true;

	/// @var {Real} Angle snapping size. Default value is 1.
	/// @see BBMOD_Gizmo.EnableAngleSnap
	AngleSnap = 1.0;

	/// @var {Real} Determines the space in which are the selected instances
	/// transformed. Use values from {@link BBMOD_EEditSpace}.
	EditSpace = BBMOD_EEditSpace.Global;

	/// @var {Real} Determines how are the selected instances transformed
	/// (translated/rotated/scaled. Use values from {@link BBMOD_EEditType}.
	EditType = BBMOD_EEditType.Position;

	/// @var {Real} Determines on which axes are the selected instances edited.
	/// Use values from {@link BBMOD_EEditAxis}.
	EditAxis = BBMOD_EEditAxis.None;

	/// @var {Constant.MouseButton} The mouse button used for dragging the gizmo.
	/// Default is `mb_left`.
	ButtonDrag = mb_left;

	/// @var {Constant.VirtualKey} The virtual key used to switch to the next
	/// edit type. Default is `vk_tab`.
	/// @see BBMOD_Gizmo.EditType
	KeyNextEditType = vk_tab;

	/// @var {Constant.VirtualKey} The virtual key used to switch to the next
	/// edit space. Default is `vk_space`.
	/// @see BBMOD_Gizmo.EditSpace
	KeyNextEditSpace = vk_space;

	/// @var {Constant.VirtualKey} The virtual key used to increase
	/// speed of editing (e.g. rotate objects by a larger angle). Default is
	/// `vk_shift`.
	KeyEditFaster = vk_shift;

	/// @var {Constant.VirtualKey} The virtual key used to decrease
	/// speed of editing (e.g. rotate objects by a smaller angle). Default is
	/// `vk_control`.
	KeyEditSlower = vk_control;

	/// @var {Constant.VirtualKey} The virtual key used to cancel editing and
	/// revert changes. Default is `vk_escape`.
	KeyCancel = vk_escape;

	/// @var {Constant.VirtualKey} The virtual key used to ignore grid and
	/// angle snapping when they are enabled. Default is `vk_alt`.
	/// @see BBMOD_Gizmo.EnableGridSnap
	/// @see BBMOD_Gizmo.EnableAngleSnap
	KeyIgnoreSnap = vk_alt;

	/// @var {Real} The size of the gizmo. Default value is 10.
	Size = _size;

	/// @var {Struct.BBMOD_Vec3} The gizmo's position in world-space.
	/// @readonly
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The gizmo's position in world-space before
	/// editing started or `undefined`.
	/// @private
	__positionBackup = undefined;

	/// @var {Struct.BBMOD_Vec3} The gizmo's rotation in euler angles.
	Rotation = new BBMOD_Vec3();

	/// @var {Id.DsList<Id.Instance>} A list of selected instances.
	/// @readonly
	Selected = ds_list_create();

	/// @var {Id.DsList<Struct>} A list of selected scene nodes.
	/// @readonly
	SelectedNodes = ds_list_create();

	/// @var {Id.DsList<Struct>} A list of additional data required for editing
	/// instances, e.g. their original offset from the gizmo, rotation and scale.
	/// @private
	__instanceData = ds_list_create();

	/// @var {Id.DsList<Struct>} A list of additional data required for editing
	/// selected scene nodes.
	/// @private
	__nodeData = ds_list_create();

	/// @var {Struct.BBMOD_Vec3} The current scaling factor of selected instances.
	/// @private
	__scaleBy = new BBMOD_Vec3(0.0);

	/// @var {Struct.BBMOD_Vec3} The current euler angles we are rotating selected
	/// instances by.
	/// @private
	__rotateBy = new BBMOD_Vec3(0.0);

	/// @var {Function} A function that the gizmo uses to check whether an instance
	/// exists. Must take the instance as the first argument and return a bool.
	/// Defaults a function that returns the result of `instance_exists`.
	InstanceExists = function (_instance)
	{
		gml_pragma("forceinline");
		return instance_exists(_instance);
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// global matrix. Normally this is an identity matrix. If the instance is
	/// attached to another instance for example, then this will be that
	/// instance's transformation matrix. Must take the instance as the first
	/// argument and return a {@link BBMOD_Matrix}. Defaults to a function that
	/// always returns an identity matrix.
	GetInstanceGlobalMatrix = function (_instance)
	{
		gml_pragma("forceinline");
		return new BBMOD_Matrix();
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// position on the X axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's `x`
	/// variable.
	GetInstancePositionX = function (_instance)
	{
		gml_pragma("forceinline");
		return _instance.x;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// position on the X axis. Must take the instance as the first argument and
	/// its new position on the X axis as the second argument. Defaults to a
	/// function that assigns the new position to the instance's `x` variable.
	SetInstancePositionX = function (_instance, _x)
	{
		gml_pragma("forceinline");
		_instance.x = _x;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// position on the Y axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's `y`
	/// variable.
	GetInstancePositionY = function (_instance)
	{
		gml_pragma("forceinline");
		return _instance.y;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// position on the Y axis. Must take the instance as the first argument and
	/// its new position on the Y axis as the second argument. Defaults to a
	/// function that assigns the new position to the instance's `y` variable.
	SetInstancePositionY = function (_instance, _y)
	{
		gml_pragma("forceinline");
		_instance.y = _y;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// position on the Z axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's `z`
	/// variable.
	GetInstancePositionZ = function (_instance)
	{
		gml_pragma("forceinline");
		return _instance.z;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// position on the Z axis. Must take the instance as the first argument and
	/// its new position on the Z axis as the second argument. Defaults to a
	/// function that assigns the new position to the instance's `Z` variable.
	SetInstancePositionZ = function (_instance, _z)
	{
		gml_pragma("forceinline");
		_instance.z = _z;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// rotation on the X axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that always returns 0.
	GetInstanceRotationX = function (_instance)
	{
		gml_pragma("forceinline");
		return 0.0;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// rotation on the X axis. Must take the instance as the first argument and
	/// its new rotation on the X axis as the second argument. Defaults to a
	/// function that does not do anything.
	SetInstanceRotationX = function (_instance, _x)
	{
		gml_pragma("forceinline");
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// rotation on the Y axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that always returns 0.
	GetInstanceRotationY = function (_instance)
	{
		gml_pragma("forceinline");
		return 0.0;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// rotation on the Y axis. Must take the instance as the first argument and
	/// its new rotation on the Y axis as the second argument. Defaults to a
	/// function that does not do anything.
	SetInstanceRotationY = function (_instance, _y)
	{
		gml_pragma("forceinline");
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// rotation on the Z axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's
	/// `image_angle` variable.
	GetInstanceRotationZ = function (_instance)
	{
		gml_pragma("forceinline");
		return _instance.image_angle;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// rotation on the Z axis. Must take the instance as the first argument and
	/// its new rotation on the Z axis as the second argument. Defaults to a
	/// function that assigns the new rotation to the instance's `image_angle`
	/// variable.
	SetInstanceRotationZ = function (_instance, _z)
	{
		gml_pragma("forceinline");
		_instance.image_angle = _z;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// scale on the X axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's
	/// `image_xscale` variable.
	GetInstanceScaleX = function (_instance)
	{
		gml_pragma("forceinline");
		return _instance.image_xscale;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// scale on the X axis. Must take the instance as the first argument and
	/// its new scale on the X axis as the second argument. Defaults to a
	/// function that assigns the new scale to the instance's `image_xscale`
	/// variable.
	SetInstanceScaleX = function (_instance, _x)
	{
		gml_pragma("forceinline");
		_instance.image_xscale = _x;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// scale on the Y axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's
	/// `image_yscale` variable.
	GetInstanceScaleY = function (_instance)
	{
		gml_pragma("forceinline");
		return _instance.image_yscale;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// scale on the Y axis. Must take the instance as the first argument and
	/// its new scale on the Y axis as the second argument. Defaults to a
	/// function that assigns the new scale to the instance's `image_yscale`
	/// variable.
	SetInstanceScaleY = function (_instance, _y)
	{
		gml_pragma("forceinline");
		_instance.image_yscale = _y;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// scale on the Z axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that always returns 1.
	GetInstanceScaleZ = function (_instance)
	{
		gml_pragma("forceinline");
		return 1.0;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// scale on the Z axis. Must take the instance as the first argument and
	/// its new scale on the Z axis as the second argument. Defaults to a
	/// function that does not do anything.
	SetInstanceScaleZ = function (_instance, _z)
	{
		gml_pragma("forceinline");
	};

	/// @func get_instance_position_vec3(_instance)
	///
	/// @desc Retrieves an instance's position as {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	///
	/// @return {Struct.BBMOD_Vec3} The instance's position.
	static get_instance_position_vec3 = function (_instance)
	{
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstancePositionX(_instance),
			GetInstancePositionY(_instance),
			GetInstancePositionZ(_instance));
	};

	/// @func set_instance_position_vec3(_instance, _position)
	///
	/// @desc Changes an instance's position using a {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @param {Struct.BBMOD_Vec3} _position The new position of the instance.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static set_instance_position_vec3 = function (_instance, _position)
	{
		gml_pragma("forceinline");
		SetInstancePositionX(_instance, _position.X);
		SetInstancePositionY(_instance, _position.Y);
		SetInstancePositionZ(_instance, _position.Z);
		return self;
	};

	/// @func get_instance_rotation_vec3(_instance)
	///
	/// @desc Retrieves an instance's rotation as {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	///
	/// @return {Struct.BBMOD_Vec3} The instance's rotation in euler angles.
	static get_instance_rotation_vec3 = function (_instance)
	{
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstanceRotationX(_instance),
			GetInstanceRotationY(_instance),
			GetInstanceRotationZ(_instance));
	};

	/// @func set_instance_rotation_vec3(_instance, _rotation)
	///
	/// @desc Changes an instance's rotation using a {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @param {Struct.BBMOD_Vec3} _rotation The new rotation of the instance
	/// in euler angles.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static set_instance_rotation_vec3 = function (_instance, _rotation)
	{
		gml_pragma("forceinline");
		SetInstanceRotationX(_instance, _rotation.X);
		SetInstanceRotationY(_instance, _rotation.Y);
		SetInstanceRotationZ(_instance, _rotation.Z);
		return self;
	};

	/// @func get_instance_scale_vec3(_instance)
	///
	/// @desc Retrieves an instance's scale as {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	///
	/// @return {Struct.BBMOD_Vec3} The instance's scale.
	static get_instance_scale_vec3 = function (_instance)
	{
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstanceScaleX(_instance),
			GetInstanceScaleY(_instance),
			GetInstanceScaleZ(_instance));
	};

	/// @func set_instance_scale_vec3(_instance, _scale)
	///
	/// @desc Changes an instance's scale using a {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @param {Struct.BBMOD_Vec3} _scale The new scale of the instance.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static set_instance_scale_vec3 = function (_instance, _scale)
	{
		gml_pragma("forceinline");
		SetInstanceScaleX(_instance, _scale.X);
		SetInstanceScaleY(_instance, _scale.Y);
		SetInstanceScaleZ(_instance, _scale.Z);
		return self;
	};

	/// @private
	static __editor_array_contains = function (_array, _value)
	{
		gml_pragma("forceinline");
		var i = 0;
		repeat(array_length(_array))
		{
			if (_array[i++] == _value)
			{
				return true;
			}
		}
		return false;
	};

	/// @private
	static __editor_node_exists = function (_target)
	{
		var _scene = bbmod_scene_get_current();

		switch (_target.SceneNodeKind)
		{
			case BBMOD_ESceneNodeType.PointLight:
			case BBMOD_ESceneNodeType.SpotLight:
				return __editor_array_contains(_scene.LightsPunctual, _target);

			case BBMOD_ESceneNodeType.DirectionalLight:
				return (_scene.LightDirectional == _target);

			case BBMOD_ESceneNodeType.ReflectionProbe:
				return __editor_array_contains(_scene.ReflectionProbes, _target);

			case BBMOD_ESceneNodeType.ParticleEmitter:
				return __editor_array_contains(_scene.ParticleEmitters, _target);

			case BBMOD_ESceneNodeType.Terrain:
				return __editor_array_contains(_scene.Terrains, _target);

			case BBMOD_ESceneNodeType.LensFlare:
				return __editor_array_contains(_scene.LensFlares, _target);
		}

		return true;
	};

	/// @private
	static __editor_node_get_position_vec3 = function (_target)
	{
		gml_pragma("forceinline");
		return _target.Position;
	};

	/// @private
	static __editor_node_set_position_vec3 = function (_target, _position)
	{
		gml_pragma("forceinline");
		if (_target.SceneNodeKind == BBMOD_ESceneNodeType.DirectionalLight
			|| _target.SceneNodeKind == BBMOD_ESceneNodeType.ReflectionProbe
			|| _target.SceneNodeKind == BBMOD_ESceneNodeType.LensFlare)
		{
			_target.set_position(_position);
		}
		else
		{
			_target.Position = _position;
			_target.mark_transform_dirty();
		}
	};

	/// @private
	static __editor_node_uses_direction = function (_target)
	{
		gml_pragma("forceinline");
		return (_target.SceneNodeKind == BBMOD_ESceneNodeType.DirectionalLight
			|| _target.SceneNodeKind == BBMOD_ESceneNodeType.SpotLight
			|| (_target.SceneNodeKind == BBMOD_ESceneNodeType.LensFlare
				&& (_target.DirectionalLight != undefined
					|| _target.Direction != undefined)));
	};

	/// @private
	static __editor_node_get_direction = function (_target)
	{
		gml_pragma("forceinline");
		if (_target.SceneNodeKind == BBMOD_ESceneNodeType.LensFlare
			&& _target.DirectionalLight != undefined)
		{
			return _target.DirectionalLight.Direction;
		}
		return _target.Direction;
	};

	/// @private
	static __editor_node_set_direction = function (_target, _direction)
	{
		gml_pragma("forceinline");
		var _directionTarget = _target;
		if (_target.SceneNodeKind == BBMOD_ESceneNodeType.LensFlare
			&& _target.DirectionalLight != undefined)
		{
			_directionTarget = _target.DirectionalLight;
		}

		_directionTarget.Direction = _direction;
	};

	/// @private
	static __editor_node_get_rotation_vec3 = function (_target)
	{
		if (__editor_node_uses_direction(_target))
		{
			var _euler = new BBMOD_Quaternion()
				.FromLookRotation(__editor_node_get_direction(_target), BBMOD_VEC3_UP)
				.ToEuler();
			return new BBMOD_Vec3(_euler[0], _euler[1], _euler[2]);
		}

		if (_target.SceneNodeKind == BBMOD_ESceneNodeType.Model)
		{
			return _target.Rotation;
		}

		return new BBMOD_Vec3();
	};

	/// @private
	static __editor_node_set_rotation_vec3 = function (_target, _rotation)
	{
		if (__editor_node_uses_direction(_target))
		{
			__editor_node_set_direction(
				_target,
				new BBMOD_Quaternion()
				.FromEuler(_rotation.X, _rotation.Y, _rotation.Z)
				.Rotate(BBMOD_VEC3_FORWARD)
				.Normalize());
		}
		else if (_target.SceneNodeKind == BBMOD_ESceneNodeType.Model)
		{
			_target.Rotation = _rotation;
			_target.mark_transform_dirty();
		}
	};

	/// @private
	static __editor_node_get_scale_vec3 = function (_target)
	{
		if (_target.SceneNodeKind == BBMOD_ESceneNodeType.PointLight)
		{
			return new BBMOD_Vec3(_target.Range);
		}

		if (_target.SceneNodeKind == BBMOD_ESceneNodeType.SpotLight)
		{
			return new BBMOD_Vec3(
				_target.Range,
				tan(degtorad(_target.AngleInner)) * _target.Range,
				tan(degtorad(_target.AngleOuter)) * _target.Range);
		}

		if (_target.SceneNodeKind == BBMOD_ESceneNodeType.ReflectionProbe)
		{
			return _target.Size;
		}

		if (_target.SceneNodeKind == BBMOD_ESceneNodeType.Terrain)
		{
			return _target.Scale;
		}

		if (_target.SceneNodeKind == BBMOD_ESceneNodeType.Model)
		{
			return _target.Scale;
		}

		return new BBMOD_Vec3(1.0);
	};

	/// @private
	static __editor_node_get_uniform_scale_by = function ()
	{
		var _scaleBy = __scaleBy.X;
		if (abs(__scaleBy.Y) > abs(_scaleBy))
		{
			_scaleBy = __scaleBy.Y;
		}
		if (abs(__scaleBy.Z) > abs(_scaleBy))
		{
			_scaleBy = __scaleBy.Z;
		}
		return _scaleBy;
	};

	/// @private
	static __editor_node_get_spot_scale_by = function (_target, _forwardGizmo, _rightGizmo, _upGizmo)
	{
		var _forward = _target.Direction.Normalize();
		var _right = _forward.Cross(BBMOD_VEC3_UP);
		if (_right.LengthSqr() <= math_get_epsilon())
		{
			_right = _forward.Cross(BBMOD_VEC3_RIGHT);
		}
		_right = _right.Normalize();
		var _up = _right.Cross(_forward).Normalize();

		var _rangeScaleBy = __scaleBy.X * abs(_forwardGizmo.Dot(_forward))
			+ __scaleBy.Y * abs(_rightGizmo.Dot(_forward))
			+ __scaleBy.Z * abs(_upGizmo.Dot(_forward));
		var _innerRadiusScaleBy = __scaleBy.X * abs(_forwardGizmo.Dot(_up))
			+ __scaleBy.Y * abs(_rightGizmo.Dot(_up))
			+ __scaleBy.Z * abs(_upGizmo.Dot(_up));
		var _outerRadiusScaleBy = __scaleBy.X * abs(_forwardGizmo.Dot(_right))
			+ __scaleBy.Y * abs(_rightGizmo.Dot(_right))
			+ __scaleBy.Z * abs(_upGizmo.Dot(_right));

		return new BBMOD_Vec3(_rangeScaleBy, _innerRadiusScaleBy, _outerRadiusScaleBy);
	};

	/// @private
	static __editor_node_set_scale_vec3 = function (_target, _scale)
	{
		if (_target.SceneNodeKind == BBMOD_ESceneNodeType.PointLight)
		{
			_target.Range = max(_scale.X, 0.0);
		}
		else if (_target.SceneNodeKind == BBMOD_ESceneNodeType.SpotLight)
		{
			var _range = max(_scale.X, 0.0);
			var _outerRadius = max(_scale.Z, 0.0);
			var _innerRadius = clamp(_scale.Y, 0.0, _outerRadius);
			var _rangeForAngle = max(_range, 0.0001);

			_target.Range = _range;
			_target.AngleOuter = clamp(
				radtodeg(arctan2(_outerRadius, _rangeForAngle)),
				0.0,
				89.0);
			_target.AngleInner = min(
				clamp(radtodeg(arctan2(_innerRadius, _rangeForAngle)), 0.0, 89.0),
				_target.AngleOuter);
		}
		else if (_target.SceneNodeKind == BBMOD_ESceneNodeType.ReflectionProbe)
		{
			_target.set_size(_scale);
		}
		else if (_target.SceneNodeKind == BBMOD_ESceneNodeType.Terrain)
		{
			_target.Scale = _scale;
		}
		else if (_target.SceneNodeKind == BBMOD_ESceneNodeType.Model)
		{
			_target.Scale = _scale;
			_target.mark_transform_dirty();
		}
	};

	/// @private
	static __editor_vec3_changed = function (_a, _b)
	{
		gml_pragma("forceinline");
		return (_a.X != _b.X || _a.Y != _b.Y || _a.Z != _b.Z);
	};

	/// @private
	static __editor_reflection_probes_need_update = function ()
	{
		var _reflectionProbes = bbmod_scene_get_current().ReflectionProbes;
		var i = 0;
		repeat(array_length(_reflectionProbes))
		{
			_reflectionProbes[i++].NeedsUpdate = true;
		}
	};

	/// @private
	static __editor_node_finish_edit = function ()
	{
		var _size = ds_list_size(SelectedNodes);
		var i = 0;
		repeat(_size)
		{
			var _target = SelectedNodes[|  i];
			var _data = __nodeData[|  i];
			var _positionChanged = __editor_vec3_changed(
				_data.Position, __editor_node_get_position_vec3(_target));
			var _rotationChanged = __editor_vec3_changed(
				_data.Rotation, __editor_node_get_rotation_vec3(_target));
			var _scaleChanged = __editor_vec3_changed(
				_data.Scale, __editor_node_get_scale_vec3(_target));
			var _transformChanged = (_positionChanged || _rotationChanged || _scaleChanged);

			if (_transformChanged
				&& (_target.EditorFlags & BBMOD_EEditorFlag.RefreshReflectionProbes))
			{
				__editor_reflection_probes_need_update();
			}

			switch (_target.SceneNodeKind)
			{
				case BBMOD_ESceneNodeType.PointLight:
				case BBMOD_ESceneNodeType.SpotLight:
				case BBMOD_ESceneNodeType.DirectionalLight:
					if (_transformChanged)
					{
						if (_target.Static && _target.CastShadows)
						{
							_target.NeedsUpdate = true;
						}
					}
					break;

				case BBMOD_ESceneNodeType.ReflectionProbe:
					if (_positionChanged || _scaleChanged)
					{
						_target.NeedsUpdate = true;
					}
					break;
			}

			++i;
		}
	};

	/// @func select(_instance)
	///
	/// @desc Adds an instance to selection.
	///
	/// @param {Id.Instance} _instance The instance to select.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static select = function (_instance)
	{
		gml_pragma("forceinline");
		if (!is_selected(_instance))
		{
			ds_list_add(Selected, _instance);
			ds_list_add(__instanceData,
			{
				Offset: new BBMOD_Vec3(),
				Rotation: new BBMOD_Vec3(),
				Scale: new BBMOD_Vec3(),
			});
		}
		return self;
	};

	/// @func select_node(_target)
	///
	/// @desc Adds a scene node to selection.
	///
	/// @param {Struct} _target The scene node to select.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static select_node = function (_target)
	{
		if (!is_node_selected(_target))
		{
			var _position = __editor_node_get_position_vec3(_target);
			var _rotation = __editor_node_get_rotation_vec3(_target);
			var _scale = __editor_node_get_scale_vec3(_target);
			var _direction = undefined;

			if (__editor_node_uses_direction(_target))
			{
				_direction = __editor_node_get_direction(_target).Clone();
			}

			ds_list_add(SelectedNodes, _target);
			ds_list_add(__nodeData,
			{
				Offset: new BBMOD_Vec3(),
				Position: _position.Clone(),
				Rotation: _rotation.Clone(),
				Scale: _scale.Clone(),
				Direction: _direction,
			});
		}
		return self;
	};

	/// @func is_selected(_instance)
	///
	/// @desc Checks whether an instance is selected.
	///
	/// @param {Id.Instance} _instance The instance to check.
	///
	/// @return {Bool} Returns `true` if the instance is selected.
	static is_selected = function (_instance)
	{
		gml_pragma("forceinline");
		return (ds_list_find_index(Selected, _instance) != -1);
	};

	/// @func is_node_selected(_target)
	///
	/// @desc Checks whether a scene node is selected.
	///
	/// @param {Struct} _target The scene node to check.
	///
	/// @return {Bool} Returns `true` if the scene node is selected.
	static is_node_selected = function (_target)
	{
		gml_pragma("forceinline");
		return (ds_list_find_index(SelectedNodes, _target) != -1);
	};

	/// @func unselect(_instance)
	///
	/// @desc Removes an instance from selection.
	///
	/// @param {Id.Instance} _instance The instance to unselect.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static unselect = function (_instance)
	{
		gml_pragma("forceinline");
		var _index = ds_list_find_index(Selected, _instance);
		if (_index != -1)
		{
			ds_list_delete(Selected, _index);
			ds_list_delete(__instanceData, _index);
		}
		return self;
	};

	/// @func unselect_node(_target)
	///
	/// @desc Removes a scene node from selection.
	///
	/// @param {Struct} _target The scene node to unselect.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static unselect_node = function (_target)
	{
		gml_pragma("forceinline");
		var _index = ds_list_find_index(SelectedNodes, _target);
		if (_index != -1)
		{
			ds_list_delete(SelectedNodes, _index);
			ds_list_delete(__nodeData, _index);
		}
		return self;
	};

	/// @func toggle_select(_instance)
	///
	/// @desc Unselects an instance if it's selected, or selects if it isn't.
	///
	/// @param {Id.Instance} _instance The instance to toggle selection of.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static toggle_select = function (_instance)
	{
		gml_pragma("forceinline");
		if (is_selected(_instance))
		{
			unselect(_instance);
		}
		else
		{
			select(_instance);
		}
		return self;
	};

	/// @func toggle_select_node(_target)
	///
	/// @desc Unselects a scene node if selected, or selects it if it isn't.
	///
	/// @param {Struct} _target The scene node to toggle selection of.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static toggle_select_node = function (_target)
	{
		gml_pragma("forceinline");
		if (is_node_selected(_target))
		{
			unselect_node(_target);
		}
		else
		{
			select_node(_target);
		}
		return self;
	};

	/// @func clear_selection()
	///
	/// @desc Removes all instances from selection.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static clear_selection = function ()
	{
		gml_pragma("forceinline");
		ds_list_clear(Selected);
		ds_list_clear(__instanceData);
		ds_list_clear(SelectedNodes);
		ds_list_clear(__nodeData);
		return self;
	};

	/// @func intersect_ray_plane(_origin, _direction, _plane, _normal)
	///
	/// @desc Intersects a ray with a plane.
	///
	/// @param {Struct.BBMOD_Vec3} _origin The ray origin.
	/// @param {Struct.BBMOD_Vec3} _direction The ray direction.
	/// @param {Struct.BBMOD_Vec3} _plane The plane origin.
	/// @param {Struct.BBMOD_Vec3} _normal The plane normal.
	///
	/// @return {Struct.BBMOD_Vec3} The point of intersection or `undefined`.
	///
	/// @private
	static intersect_ray_plane = function (_origin, _direction, _plane, _normal)
	{
		var _dot = _direction.Dot(_normal);
		if (_dot == 0.0)
		{
			return undefined;
		}
		var _t = -(_origin.Sub(_plane).Dot(_normal) / _dot);
		return _origin.Add(_direction.Scale(_t));
	};

	/// @func update_position()
	///
	/// @desc Updates the gizmo's position, based on its selected instances.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static update_position = function ()
	{
		var _size = ds_list_size(Selected);
		var _sizeNodes = ds_list_size(SelectedNodes);
		var _sizeTotal = _size + _sizeNodes;
		var _posX = 0.0;
		var _posY = 0.0;
		var _posZ = 0.0;

		for (var i = _size - 1; i >= 0; --i)
		{
			var _instance = Selected[|  i];

			if (!InstanceExists(_instance))
			{
				ds_list_delete(Selected, i);
				ds_list_delete(__instanceData, i);
				--_size;
				continue;
			}

			_posX += GetInstancePositionX(_instance);
			_posY += GetInstancePositionY(_instance);
			_posZ += GetInstancePositionZ(_instance);
		}

		for (var i = _sizeNodes - 1; i >= 0; --i)
		{
			var _target = SelectedNodes[|  i];

			if (!__editor_node_exists(_target))
			{
				ds_list_delete(SelectedNodes, i);
				ds_list_delete(__nodeData, i);
				--_sizeNodes;
				--_sizeTotal;
				continue;
			}

			var _position = __editor_node_get_position_vec3(_target);
			_posX += _position.X;
			_posY += _position.Y;
			_posZ += _position.Z;
		}

		if (_sizeTotal > 0)
		{
			_posX /= _sizeTotal;
			_posY /= _sizeTotal;
			_posZ /= _sizeTotal;

			Position.Set(_posX, _posY, _posZ);

			if (EditSpace == BBMOD_EEditSpace.Local)
			{
				if (_sizeNodes > 0)
				{
					var _lastSelectedNode = SelectedNodes[|  _sizeNodes - 1];
					__editor_node_get_rotation_vec3(_lastSelectedNode).Copy(Rotation);
				}
				else
				{
					var _lastSelected = Selected[|  _size - 1];
					Rotation.Set(
						GetInstanceRotationX(_lastSelected),
						GetInstanceRotationY(_lastSelected),
						GetInstanceRotationZ(_lastSelected));
				}
			}
			else
			{
				Rotation.Set(0.0, 0.0, 0.0);
			}
		}

		return self;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Updates the gizmo. Should be called every frame.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	///
	/// @note This requires you to use a {@link BBMOD_BaseCamera} and it will
	/// not do anything if its [apply](./BBMOD_BaseCamera.apply.html) method has
	/// not been called yet!
	static update = function (_deltaTime)
	{
		var _camera = bbmod_scene_get_current().CameraCurrent ?? global.__bbmodCameraCurrent;
		if (_camera == undefined)
		{
			return self;
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Not editing or finished editing
		//
		if (!IsEditing || !mouse_check_button(ButtonDrag))
		{
			if (IsEditing)
			{
				__editor_node_finish_edit();
			}

			if (KeyNextEditType != undefined
				&& keyboard_check_pressed(KeyNextEditType))
			{
				if (++EditType >= BBMOD_EEditType.SIZE)
				{
					EditType = 0;
				}
			}

			if (KeyNextEditSpace != undefined
				&& keyboard_check_pressed(KeyNextEditSpace))
			{
				if (++EditSpace >= BBMOD_EEditSpace.SIZE)
				{
					EditSpace = 0;
				}
			}

			// Compute gizmo's new position
			var _size = ds_list_size(Selected);
			var _sizeNodes = ds_list_size(SelectedNodes);
			var _sizeTotal = _size + _sizeNodes;
			var _posX = 0.0;
			var _posY = 0.0;
			var _posZ = 0.0;

			for (var i = _size - 1; i >= 0; --i)
			{
				var _instance = Selected[|  i];

				if (!InstanceExists(_instance))
				{
					ds_list_delete(Selected, i);
					ds_list_delete(__instanceData, i);
					--_size;
					continue;
				}

				_posX += GetInstancePositionX(_instance);
				_posY += GetInstancePositionY(_instance);
				_posZ += GetInstancePositionZ(_instance);
			}

			for (var i = _sizeNodes - 1; i >= 0; --i)
			{
				var _target = SelectedNodes[|  i];

				if (!__editor_node_exists(_target))
				{
					ds_list_delete(SelectedNodes, i);
					ds_list_delete(__nodeData, i);
					--_sizeNodes;
					--_sizeTotal;
					continue;
				}

				var _position = __editor_node_get_position_vec3(_target);
				_posX += _position.X;
				_posY += _position.Y;
				_posZ += _position.Z;
			}

			if (_sizeTotal > 0)
			{
				_posX /= _sizeTotal;
				_posY /= _sizeTotal;
				_posZ /= _sizeTotal;

				Position.Set(_posX, _posY, _posZ);

				if (EditSpace == BBMOD_EEditSpace.Local)
				{
					if (_sizeNodes > 0)
					{
						var _lastSelectedNode = SelectedNodes[|  _sizeNodes - 1];
						__editor_node_get_rotation_vec3(_lastSelectedNode).Copy(Rotation);
					}
					else
					{
						var _lastSelected = Selected[|  _size - 1];
						var _mat = GetInstanceGlobalMatrix(_lastSelected);
						var _mat2 = new BBMOD_Matrix().RotateEuler(get_instance_rotation_vec3(_lastSelected));
						var _mat3 = _mat2.Mul(_mat);
						var _euler = _mat3.ToEuler();
						Rotation.FromArray(_euler);
					}
				}
				else
				{
					Rotation.Set(0.0, 0.0, 0.0);
				}
			}

			// Store instance data
			for (var i = _size - 1; i >= 0; --i)
			{
				var _instance = Selected[|  i];
				var _data = __instanceData[|  i];
				_data.Offset = get_instance_position_vec3(_instance).Sub(Position);
				_data.Rotation = get_instance_rotation_vec3(_instance);
				_data.Scale = get_instance_scale_vec3(_instance);
			}

			for (var i = _sizeNodes - 1; i >= 0; --i)
			{
				var _target = SelectedNodes[|  i];
				var _data = __nodeData[|  i];
				var _position = __editor_node_get_position_vec3(_target);
				_data.Offset = _position.Sub(Position);
				_data.Position = _position.Clone();
				_data.Rotation = __editor_node_get_rotation_vec3(_target);
				_data.Scale = __editor_node_get_scale_vec3(_target).Clone();

				if (__editor_node_uses_direction(_target))
				{
					_data.Direction = __editor_node_get_direction(_target).Clone();
				}
				else
				{
					_data.Direction = undefined;
				}
			}

			// Clear properties used when editing
			IsEditing = false;
			__mouseOffset = undefined;
			__mouseLockAt = undefined;
			__positionBackup = undefined;
			if (__cursorBackup != undefined)
			{
				window_set_cursor(__cursorBackup);
				__cursorBackup = undefined;
			}
			__scaleBy = new BBMOD_Vec3(0.0);
			__rotateBy = new BBMOD_Vec3(0.0);

			return self;
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Editing
		//
		var _mouseX = window_mouse_get_x();
		var _mouseY = window_mouse_get_y();

		if (!__mouseLockAt)
		{
			__mouseLockAt = new BBMOD_Vec2(_mouseX, _mouseY);
			__cursorBackup = window_get_cursor();
		}

		var _quaternionGizmo = new BBMOD_Quaternion().FromEuler(Rotation.X, Rotation.Y, Rotation.Z);
		var _forwardGizmo = _quaternionGizmo.Rotate(BBMOD_VEC3_FORWARD);
		var _rightGizmo = _quaternionGizmo.Rotate(BBMOD_VEC3_RIGHT);
		var _upGizmo = _quaternionGizmo.Rotate(BBMOD_VEC3_UP);

		// Build rotation matrix from quaternion
		var _matRot = _quaternionGizmo.ToMatrix();
		// For orthonormal matrices, inverse = transpose
		var _matRotInverse = bbmod_matrix_transpose(_matRot);

		////////////////////////////////////////////////////////////////////////
		// Handle editing
		switch (EditType)
		{
			case BBMOD_EEditType.Position:
				if (!__positionBackup)
				{
					__positionBackup = Position.Clone();
				}

				var _planeNormal;

				switch (EditAxis)
				{
					case BBMOD_EEditAxis.X:
					{
						var _dot1 = _rightGizmo.Dot(_camera.get_forward());
						var _dot2 = _upGizmo.Dot(_camera.get_forward());
						_planeNormal = (abs(_dot1) > abs(_dot2)) ? _rightGizmo : _upGizmo;
					}
					break;

					case BBMOD_EEditAxis.Y:
					{
						var _dot1 = _forwardGizmo.Dot(_camera.get_forward());
						var _dot2 = _upGizmo.Dot(_camera.get_forward());
						_planeNormal = (abs(_dot1) > abs(_dot2)) ? _forwardGizmo : _upGizmo;
					}
					break;

					case BBMOD_EEditAxis.Z:
					{
						var _dot1 = _forwardGizmo.Dot(_camera.get_forward());
						var _dot2 = _rightGizmo.Dot(_camera.get_forward());
						_planeNormal = (abs(_dot1) > abs(_dot2)) ? _forwardGizmo : _rightGizmo;
					}
					break;

					case BBMOD_EEditAxis.All:
						_planeNormal = _camera.get_forward();
						break;
				}

				var _mouseWorld = intersect_ray_plane(
					_camera.Position,
					_camera.screen_point_to_vec3(new BBMOD_Vec2(_mouseX, _mouseY), global
						.__bbmodRendererCurrent),
					__positionBackup,
					_planeNormal);

				if (_mouseWorld)
				{
					var _snap = (EnableGridSnap && !keyboard_check(KeyIgnoreSnap));

					if (EditAxis == BBMOD_EEditAxis.All)
					{
						if (!__mouseOffset)
						{
							__mouseOffset = _mouseWorld.Sub(Position);
						}

						Position = _mouseWorld.Add(__mouseOffset);
					}
					else
					{
						if (!__mouseOffset)
						{
							__mouseOffset = _mouseWorld;
						}

						var _diff = _mouseWorld.Sub(__mouseOffset);

						if (EditAxis & BBMOD_EEditAxis.X)
						{
							var _moveX = _forwardGizmo.Scale(_diff.Dot(_forwardGizmo));
							if (_snap
								&& EditSpace == BBMOD_EEditSpace.Local
								&& GridSize.X != 0.0)
							{
								var _moveXLength = _moveX.Length();
								if (_moveXLength > 0.0)
								{
									var _s = round(_moveXLength / GridSize.X) * GridSize.X;
									_moveX = _moveX.Normalize().Scale(_s);
								}
							}
							Position = __positionBackup.Add(_moveX);
						}

						if (EditAxis & BBMOD_EEditAxis.Y)
						{
							var _moveY = _rightGizmo.Scale(_diff.Dot(_rightGizmo));
							if (_snap
								&& EditSpace == BBMOD_EEditSpace.Local
								&& GridSize.Y != 0.0)
							{
								var _moveYLength = _moveY.Length();
								if (_moveYLength > 0.0)
								{
									var _s = round(_moveYLength / GridSize.Y) * GridSize.Y;
									_moveY = _moveY.Normalize().Scale(_s);
								}
							}
							Position = __positionBackup.Add(_moveY);
						}

						if (EditAxis & BBMOD_EEditAxis.Z)
						{
							var _moveZ = _upGizmo.Scale(_diff.Dot(_upGizmo));
							if (_snap
								&& EditSpace == BBMOD_EEditSpace.Local
								&& GridSize.Z != 0.0)
							{
								var _moveZLength = _moveZ.Length();
								if (_moveZLength > 0.0)
								{
									var _s = round(_moveZLength / GridSize.Z) * GridSize.Z;
									_moveZ = _moveZ.Normalize().Scale(_s);
								}
							}
							Position = __positionBackup.Add(_moveZ);
						}
					}

					if (_snap
						&& (EditSpace == BBMOD_EEditSpace.Global
							|| EditAxis == BBMOD_EEditAxis.All))
					{
						if (GridSize.X != 0.0)
						{
							Position.X = round(Position.X / GridSize.X) * GridSize.X;
						}

						if (GridSize.Y != 0.0)
						{
							Position.Y = round(Position.Y / GridSize.Y) * GridSize.Y;
						}

						if (GridSize.Z != 0.0)
						{
							Position.Z = round(Position.Z / GridSize.Z) * GridSize.Z;
						}
					}
				}
				break;

			case BBMOD_EEditType.Rotation:
			{
				_planeNormal = ((EditAxis == BBMOD_EEditAxis.X) ? _forwardGizmo
					: ((EditAxis == BBMOD_EEditAxis.Y) ? _rightGizmo
						: _upGizmo));

				_mouseWorld = intersect_ray_plane(
					_camera.Position,
					_camera.screen_point_to_vec3(new BBMOD_Vec2(_mouseX, _mouseY), global
						.__bbmodRendererCurrent),
					Position,
					_planeNormal);

				if (_mouseWorld)
				{
					if (!__mouseOffset)
					{
						__mouseOffset = _mouseWorld;
					}

					var _v1 = __mouseOffset.Sub(Position);
					var _v2 = _mouseWorld.Sub(Position);
					var _angle = darctan2(_v2.Cross(_v1).Dot(_planeNormal), _v1.Dot(_v2));

					switch (EditAxis)
					{
						case BBMOD_EEditAxis.X:
							__rotateBy.X = _angle;
							break;

						case BBMOD_EEditAxis.Y:
							__rotateBy.Y = _angle;
							break;

						case BBMOD_EEditAxis.Z:
							__rotateBy.Z = _angle;
							break;
					}
				}
			}
			break;

			case BBMOD_EEditType.Scale:
			{
				switch (EditAxis)
				{
					case BBMOD_EEditAxis.X:
					{
						var _dot1 = _rightGizmo.Dot(_camera.get_forward());
						var _dot2 = _upGizmo.Dot(_camera.get_forward());
						_planeNormal = (abs(_dot1) > abs(_dot2)) ? _rightGizmo : _upGizmo;
					}
					break;

					case BBMOD_EEditAxis.Y:
					{
						var _dot1 = _forwardGizmo.Dot(_camera.get_forward());
						var _dot2 = _upGizmo.Dot(_camera.get_forward());
						_planeNormal = (abs(_dot1) > abs(_dot2)) ? _forwardGizmo : _upGizmo;
					}
					break;

					case BBMOD_EEditAxis.Z:
					{
						var _dot1 = _forwardGizmo.Dot(_camera.get_forward());
						var _dot2 = _rightGizmo.Dot(_camera.get_forward());
						_planeNormal = (abs(_dot1) > abs(_dot2)) ? _forwardGizmo : _rightGizmo;
					}
					break;

					case BBMOD_EEditAxis.All:
						_planeNormal = _camera.get_forward();
						break;
				}

				_mouseWorld = intersect_ray_plane(
					_camera.Position,
					_camera.screen_point_to_vec3(new BBMOD_Vec2(_mouseX, _mouseY), global
						.__bbmodRendererCurrent),
					Position,
					_planeNormal);

				if (_mouseWorld && __mouseOffset)
				{
					var _mul = (keyboard_check(KeyEditFaster) ? 5.0
						: (keyboard_check(KeyEditSlower) ? 0.1
							: 1.0));

					var _diff = _mouseWorld.Sub(__mouseOffset).Scale(_mul);

					if (EditAxis == BBMOD_EEditAxis.All)
					{
						var _diffX = _diff.Mul(_forwardGizmo.Abs()).Dot(_forwardGizmo);
						var _diffY = _diff.Mul(_rightGizmo.Abs()).Dot(_rightGizmo);
						var _scaleBy = (abs(_diffX) > abs(_diffY)) ? _diffX : _diffY;
						__scaleBy.X += _scaleBy;
						__scaleBy.Y += _scaleBy;
						__scaleBy.Z += _scaleBy;
					}
					else
					{
						if (EditAxis & BBMOD_EEditAxis.X)
						{
							__scaleBy.X += _diff.Mul(_forwardGizmo.Abs()).Dot(_forwardGizmo);
						}

						if (EditAxis & BBMOD_EEditAxis.Y)
						{
							__scaleBy.Y += _diff.Mul(_rightGizmo.Abs()).Dot(_rightGizmo);
						}

						if (EditAxis & BBMOD_EEditAxis.Z)
						{
							__scaleBy.Z += _diff.Mul(_upGizmo.Abs()).Dot(_upGizmo);
						}
					}
				}

				__mouseOffset = _mouseWorld;
			}
			break;
		}

		////////////////////////////////////////////////////////////////////////
		// Cancel editing?
		if (keyboard_check_pressed(KeyCancel))
		{
			if (__positionBackup)
			{
				__positionBackup.Copy(Position);
			}
			__rotateBy.Set(0.0, 0.0, 0.0);
			__scaleBy.Set(0.0, 0.0, 0.0);
			IsEditing = false;
		}

		////////////////////////////////////////////////////////////////////////
		// Apply to selected instances
		var _size = ds_list_size(Selected);

		for (var i = _size - 1; i >= 0; --i)
		{
			var _instance = Selected[|  i];

			if (!InstanceExists(_instance))
			{
				ds_list_delete(Selected, i);
				ds_list_delete(__instanceData, i);
				--_size;
				continue;
			}

			var _data = __instanceData[|  i];
			var _positionOffset = _data.Offset;
			var _rotationStored = _data.Rotation;
			var _scaleStored = _data.Scale;

			// Get local basis
			var _quaternionInstance = new BBMOD_Quaternion().FromEuler(
				GetInstanceRotationX(_instance),
				GetInstanceRotationY(_instance),
				GetInstanceRotationZ(_instance));
			var _forwardInstance = _quaternionInstance.Rotate(BBMOD_VEC3_FORWARD);
			var _rightInstance = _quaternionInstance.Rotate(BBMOD_VEC3_RIGHT);
			var _upInstance = _quaternionInstance.Rotate(BBMOD_VEC3_UP);

			// Apply rotation
			var _matGlobal = GetInstanceGlobalMatrix(_instance).Raw;
			var _matGlobalInv = matrix_inverse(_matGlobal);
			var _rotateByX = __rotateBy.X;
			var _rotateByY = __rotateBy.Y;
			var _rotateByZ = __rotateBy.Z;

			if (EnableAngleSnap
				&& AngleSnap != 0.0
				&& !keyboard_check(KeyIgnoreSnap))
			{
				_rotateByX = floor(__rotateBy.X / AngleSnap) * AngleSnap;
				_rotateByY = floor(__rotateBy.Y / AngleSnap) * AngleSnap;
				_rotateByZ = floor(__rotateBy.Z / AngleSnap) * AngleSnap;
			}

			// Transform gizmo basis vectors to instance's local space
			var _vTemp = matrix_transform_vertex(_matGlobalInv, _forwardGizmo.X, _forwardGizmo.Y, _forwardGizmo.Z);
			var _forwardGlobal = new BBMOD_Vec3(_vTemp[0], _vTemp[1], _vTemp[2]);
			_vTemp = matrix_transform_vertex(_matGlobalInv, _rightGizmo.X, _rightGizmo.Y, _rightGizmo.Z);
			var _rightGlobal = new BBMOD_Vec3(_vTemp[0], _vTemp[1], _vTemp[2]);
			_vTemp = matrix_transform_vertex(_matGlobalInv, _upGizmo.X, _upGizmo.Y, _upGizmo.Z);
			var _upGlobal = new BBMOD_Vec3(_vTemp[0], _vTemp[1], _vTemp[2]);

			var _rotMatrix = new BBMOD_Matrix().RotateEuler(_rotationStored);
			if (_rotateByX != 0.0)
			{
				var _quaternionX = new BBMOD_Quaternion().FromAxisAngle(_forwardGlobal, _rotateByX);
				_positionOffset = _quaternionX.Rotate(_positionOffset);
				_rotMatrix = _rotMatrix.RotateQuat(_quaternionX);
			}
			if (_rotateByY != 0.0)
			{
				var _quaternionY = new BBMOD_Quaternion().FromAxisAngle(_rightGlobal, _rotateByY);
				_positionOffset = _quaternionY.Rotate(_positionOffset);
				_rotMatrix = _rotMatrix.RotateQuat(_quaternionY);
			}
			if (_rotateByZ != 0.0)
			{
				var _quaternionZ = new BBMOD_Quaternion().FromAxisAngle(_upGlobal, _rotateByZ);
				_positionOffset = _quaternionZ.Rotate(_positionOffset);
				_rotMatrix = _rotMatrix.RotateQuat(_quaternionZ);
			}
			var _rotArray = _rotMatrix.ToEuler();
			SetInstanceRotationX(_instance, _rotArray[0]);
			SetInstanceRotationY(_instance, _rotArray[1]);
			SetInstanceRotationZ(_instance, _rotArray[2]);

			// Apply scale
			var _scaleNew = _scaleStored.Clone();
			var _scaleOld = _scaleNew.Clone();

			// Scale on X
			_scaleNew.X += __scaleBy.X * abs(_forwardGlobal.Dot(_forwardInstance));
			_scaleNew.Y += __scaleBy.X * abs(_forwardGlobal.Dot(_rightInstance));
			_scaleNew.Z += __scaleBy.X * abs(_forwardGlobal.Dot(_upInstance));

			// Scale on Y
			_scaleNew.X += __scaleBy.Y * abs(_rightGlobal.Dot(_forwardInstance));
			_scaleNew.Y += __scaleBy.Y * abs(_rightGlobal.Dot(_rightInstance));
			_scaleNew.Z += __scaleBy.Y * abs(_rightGlobal.Dot(_upInstance));

			// Scale on Z
			_scaleNew.X += __scaleBy.Z * abs(_upGlobal.Dot(_forwardInstance));
			_scaleNew.Y += __scaleBy.Z * abs(_upGlobal.Dot(_rightInstance));
			_scaleNew.Z += __scaleBy.Z * abs(_upGlobal.Dot(_upInstance));

			// Scale offset
			var _vI = matrix_transform_vertex(
				_matRotInverse, _positionOffset.X, _positionOffset.Y, _positionOffset.Z);
			// Compute scale ratios (new scale / old scale)
			var _scaleRatioX = (_scaleOld.X + __scaleBy.X) / max(_scaleOld.X, 0.0001);
			var _scaleRatioY = (_scaleOld.Y + __scaleBy.Y) / max(_scaleOld.Y, 0.0001);
			var _scaleRatioZ = (_scaleOld.Z + __scaleBy.Z) / max(_scaleOld.Z, 0.0001);
			var _vIRot = matrix_transform_vertex(
				matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _scaleRatioX, _scaleRatioY, _scaleRatioZ),
				_vI[0], _vI[1], _vI[2]);
			var _v = matrix_transform_vertex(_matRot, _vIRot[0], _vIRot[1], _vIRot[2]);

			// Apply scale and position
			set_instance_scale_vec3(_instance, _scaleNew);
			SetInstancePositionX(_instance, Position.X + _v[0]);
			SetInstancePositionY(_instance, Position.Y + _v[1]);
			SetInstancePositionZ(_instance, Position.Z + _v[2]);
		}

		////////////////////////////////////////////////////////////////////////
		// Apply to selected scene nodes
		var _sizeNodes = ds_list_size(SelectedNodes);
		var _rotateByXStruct = __rotateBy.X;
		var _rotateByYStruct = __rotateBy.Y;
		var _rotateByZStruct = __rotateBy.Z;
		var _applyStructRotation = (EditType == BBMOD_EEditType.Rotation);

		if (EnableAngleSnap
			&& AngleSnap != 0.0
			&& !keyboard_check(KeyIgnoreSnap))
		{
			_rotateByXStruct = floor(__rotateBy.X / AngleSnap) * AngleSnap;
			_rotateByYStruct = floor(__rotateBy.Y / AngleSnap) * AngleSnap;
			_rotateByZStruct = floor(__rotateBy.Z / AngleSnap) * AngleSnap;
		}

		for (var i = _sizeNodes - 1; i >= 0; --i)
		{
			var _target = SelectedNodes[|  i];

			if (!__editor_node_exists(_target))
			{
				ds_list_delete(SelectedNodes, i);
				ds_list_delete(__nodeData, i);
				--_sizeNodes;
				continue;
			}

			var _data = __nodeData[|  i];
			var _positionOffset = _data.Offset;
			var _rotationStored = _data.Rotation;
			var _scaleStored = _data.Scale;

			if (_applyStructRotation
				&& (_target.EditorFlags & BBMOD_EEditorFlag.Rotate)
				&& (_rotateByXStruct != 0.0
					|| _rotateByYStruct != 0.0
					|| _rotateByZStruct != 0.0))
			{
				var _rotMatrix = new BBMOD_Matrix().RotateEuler(_rotationStored);
				var _usesDirection = __editor_node_uses_direction(_target);
				var _direction = undefined;

				if (_usesDirection)
				{
					_direction = (_data.Direction != undefined)
						? _data.Direction.Clone()
						: __editor_node_get_direction(_target).Clone();
				}

				if (_rotateByXStruct != 0.0)
				{
					var _quaternionX = new BBMOD_Quaternion().FromAxisAngle(_forwardGizmo, _rotateByXStruct);
					_positionOffset = _quaternionX.Rotate(_positionOffset);
					_rotMatrix = _rotMatrix.RotateQuat(_quaternionX);
					if (_usesDirection)
					{
						_direction = _quaternionX.Rotate(_direction);
					}
				}
				if (_rotateByYStruct != 0.0)
				{
					var _quaternionY = new BBMOD_Quaternion().FromAxisAngle(_rightGizmo, _rotateByYStruct);
					_positionOffset = _quaternionY.Rotate(_positionOffset);
					_rotMatrix = _rotMatrix.RotateQuat(_quaternionY);
					if (_usesDirection)
					{
						_direction = _quaternionY.Rotate(_direction);
					}
				}
				if (_rotateByZStruct != 0.0)
				{
					var _quaternionZ = new BBMOD_Quaternion().FromAxisAngle(_upGizmo, _rotateByZStruct);
					_positionOffset = _quaternionZ.Rotate(_positionOffset);
					_rotMatrix = _rotMatrix.RotateQuat(_quaternionZ);
					if (_usesDirection)
					{
						_direction = _quaternionZ.Rotate(_direction);
					}
				}

				if (_usesDirection)
				{
					__editor_node_set_direction(_target, _direction.Normalize());
				}
				else
				{
					var _rotArray = _rotMatrix.ToEuler();
					__editor_node_set_rotation_vec3(_target,
						new BBMOD_Vec3(_rotArray[0], _rotArray[1], _rotArray[2]));
				}
			}

			if (_target.EditorFlags & BBMOD_EEditorFlag.Scale)
			{
				var _scaleNew = _scaleStored.Clone();
				if (_target.SceneNodeKind == BBMOD_ESceneNodeType.PointLight)
				{
					var _scaleBy = __editor_node_get_uniform_scale_by();
					_scaleNew.X += _scaleBy;
					_scaleNew.Y += _scaleBy;
					_scaleNew.Z += _scaleBy;
				}
				else if (_target.SceneNodeKind == BBMOD_ESceneNodeType.SpotLight)
				{
					_scaleNew.AddSelf(__editor_node_get_spot_scale_by(
						_target,
						_forwardGizmo,
						_rightGizmo,
						_upGizmo));
				}
				else
				{
					_scaleNew.X += __scaleBy.X;
					_scaleNew.Y += __scaleBy.Y;
					_scaleNew.Z += __scaleBy.Z;
				}

				var _vI = matrix_transform_vertex(
					_matRotInverse, _positionOffset.X, _positionOffset.Y, _positionOffset.Z);
				var _scaleRatioX = _scaleNew.X / max(_scaleStored.X, 0.0001);
				var _scaleRatioY = _scaleNew.Y / max(_scaleStored.Y, 0.0001);
				var _scaleRatioZ = _scaleNew.Z / max(_scaleStored.Z, 0.0001);
				var _vIRot = matrix_transform_vertex(
					matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _scaleRatioX, _scaleRatioY, _scaleRatioZ),
					_vI[0], _vI[1], _vI[2]);
				var _v = matrix_transform_vertex(_matRot, _vIRot[0], _vIRot[1], _vIRot[2]);
				_positionOffset = new BBMOD_Vec3(_v[0], _v[1], _v[2]);

				__editor_node_set_scale_vec3(_target, _scaleNew);
			}

			if (_target.EditorFlags & BBMOD_EEditorFlag.Translate)
			{
				__editor_node_set_position_vec3(_target,
					new BBMOD_Vec3(
						Position.X + _positionOffset.X,
						Position.Y + _positionOffset.Y,
						Position.Z + _positionOffset.Z));
			}
		}

		return self;
	};

	/// @func submit([_materials])
	///
	/// @desc Immediately submits the gizmo for rendering.
	///
	/// @param {Array<Struct.BBMOD_Material>} [_materials] Materials to use or
	/// `undefined`.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	///
	/// @note This changes the world matrix based on the gizmo's position and size!
	static submit = function (_materials = undefined)
	{
		gml_pragma("forceinline");
		(new BBMOD_Matrix())
		.Scale(new BBMOD_Vec3(Size))
			.RotateEuler(Rotation)
			.Translate(Position)
			.ApplyWorld();
		Models[EditType].submit(_materials);
		return self;
	};

	/// @func render([_materials])
	///
	/// @desc Enqueues the gizmo for rendering.
	///
	/// @param {Array<Struct.BBMOD_Material>} [_materials] Materials to use or
	/// `undefined`.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	///
	/// @note This changes the world matrix based on the gizmo's position and size!
	static render = function (_materials = undefined)
	{
		gml_pragma("forceinline");
		new BBMOD_Matrix()
			.Scale(new BBMOD_Vec3(Size))
			.RotateEuler(Rotation)
			.Translate(Position)
			.ApplyWorld();
		Models[EditType].render(_materials);
		return self;
	};

	static destroy = function ()
	{
		ds_list_destroy(Selected);
		ds_list_destroy(SelectedNodes);
		ds_list_destroy(__instanceData);
		ds_list_destroy(__nodeData);
		return undefined;
	};
}
