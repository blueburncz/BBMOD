/// @enum Enumeration of edit spaces.
enum BBMOD_EEditSpace
{
	/// @member Edit instances in world-space.
	World,
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
/// @extends BBMOD_Class
/// @desc A gizmo for transforming instances.
/// @param {Real} [_size] The size of the gizmo. Default value is 10 units.
function BBMOD_Gizmo(_size=10.0)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Struct.BBMOD_Model} The gizmo model.
	/// @note Please note that this model is not loaded asynchronnously,
	/// therefore it cannot be used on platforms that require asynchronnous
	/// loading, like HTML5!
	/// @readonly
	static Model = undefined;

	/// @var {Array<Struct.BBMOD_Material>} Materials used when mouse-picking
	/// the gizmo.
	static MaterialsSelect = undefined;

	if (!Model)
	{
		var _shaderSelect = new BBMOD_BaseShader(BBMOD_ShGizmoSelect, BBMOD_VFORMAT_DEFAULT);
		var _materialSelect = new BBMOD_BaseMaterial(_shaderSelect);
		_materialSelect.BaseOpacity = sprite_get_texture(BBMOD_SprGizmo, 1);
		_materialSelect.Culling = cull_noculling;
		MaterialsSelect = [_materialSelect];

		var _shader = new BBMOD_BaseShader(BBMOD_ShGizmo, BBMOD_VFORMAT_DEFAULT);
		var _material = new BBMOD_BaseMaterial(_shader);
		_material.BaseOpacity = sprite_get_texture(BBMOD_SprGizmo, 0);
		_material.Culling = cull_noculling;

		Model = new BBMOD_Model("Data/BBMOD/Models/Gizmo.bbmod")
		Model.Materials[0] = _material;
	}

	/// @var {Bool} Used to show/hide the gizmo. Default value is `true`, which
	/// makes it visible.
	/// @obsolete
	Visible = true;

	/// @var {Bool} If `true` then the gizmo is editing selected instances.
	IsEditing = false;

	/// @var {Struct.BBMOD_Vec2/Undefined}
	/// @private
	MouseLockAt = undefined;

	/// @var {Struct.BBMOD_Vec3/Undefined}
	/// @private
	MouseOffset = undefined;

	/// @var {Constant.Cursor}
	/// @private
	CursorBackup = undefined;

	/// @var {Enum.BBMOD_EEditSpace} Determines the space in which are the
	/// selected instances transformed.
	/// @see BBMOD_EEditSpace
	EditSpace = BBMOD_EEditSpace.World;

	/// @var {Enum.BBMOD_EEditType} Determines how are the selected instances
	/// transformed (translated/rotated/scaled).
	/// @see BBMOD_EEditType
	EditType = BBMOD_EEditType.Position;

	/// @var {Enum.BBMOD_EEditAxis} Determines on which axes are the selected
	/// instances edited.
	/// @see BBMOD_EEditAxis
	EditAxis = BBMOD_EEditAxis.None;

	/// @var {Constant.MouseButton}
	ButtonDrag = mb_left;

	///// @var {Constant.VirtualKey}
	//KeyNextEditType = vk_tab;

	/// @var {Constant.VirtualKey}
	KeyNextEditSpace = vk_space;

	/// @var {Constant.VirtualKey}
	KeyEditFaster = vk_shift;

	/// @var {Constant.VirtualKey}
	KeyEditSlower = vk_control;

	/// @var {Real} The size of the gizmo. Default value is 10.
	Size = _size;

	/// @var {Struct.BBMOD_Vec3} The gizmo's position in world-space.
	/// @readonly
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3/Undefined}
	/// @private
	PositionBackup = undefined;

	/// @var {Struct.BBMOD_Vec3} The gizmo's rotation in euler angles.
	Rotation = new BBMOD_Vec3();

	/// @var {Id.DsList<Id.Instance>} A list of selected instances.
	/// @readonly
	Selected = ds_list_create();

	InstanceExists = function (_instance) {
		gml_pragma("forceinline");
		return instance_exists(_instance);
	};

	GetInstancePositionX = function (_instance) {
		gml_pragma("forceinline");
		return _instance.x;
	};

	SetInstancePositionX = function (_instance, _x) {
		gml_pragma("forceinline");
		_instance.x = _x;
	};

	GetInstancePositionY = function (_instance) {
		gml_pragma("forceinline");
		return _instance.y;
	};

	SetInstancePositionY = function (_instance, _y) {
		gml_pragma("forceinline");
		_instance.y = _y;
	};

	GetInstancePositionZ = function (_instance) {
		gml_pragma("forceinline");
		return _instance.z;
	};

	SetInstancePositionZ = function (_instance, _z) {
		gml_pragma("forceinline");
		_instance.z = _z;
	};

	GetInstanceRotationX = function (_instance) {
		gml_pragma("forceinline");
		return 0.0;
	};

	SetInstanceRotationX = function (_instance, _x) {
		gml_pragma("forceinline");
	};

	GetInstanceRotationY = function (_instance) {
		gml_pragma("forceinline");
		return 0.0;
	};

	SetInstanceRotationY = function (_instance, _y) {
		gml_pragma("forceinline");
	};

	GetInstanceRotationZ = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_angle;
	};

	SetInstanceRotationZ = function (_instance, _z) {
		gml_pragma("forceinline");
		_instance.image_angle = _z;
	};

	GetInstanceScaleX = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_xscale;
	};

	SetInstanceScaleX = function (_instance, _x) {
		gml_pragma("forceinline");
		_instance.image_xscale = _x;
	};

	GetInstanceScaleY = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_yscale;
	};

	SetInstanceScaleY = function (_instance, _y) {
		gml_pragma("forceinline");
		_instance.image_yscale = _y;
	};

	GetInstanceScaleZ = function (_instance) {
		gml_pragma("forceinline");
		return 1.0;
	};

	SetInstanceScaleZ = function (_instance, _z) {
		gml_pragma("forceinline");
	};

	static GetInstancePositionVec3 = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstancePositionX(_instance),
			GetInstancePositionY(_instance),
			GetInstancePositionZ(_instance));
	};

	static SetInstancePositionVec3 = function (_instance, _position) {
		gml_pragma("forceinline");
		SetInstancePositionX(_instance, _position.X);
		SetInstancePositionY(_instance, _position.Y);
		SetInstancePositionZ(_instance, _position.Z);
		return self;
	};

	static GetInstanceRotationVec3 = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstanceRotationX(_instance),
			GetInstanceRotationY(_instance),
			GetInstanceRotationZ(_instance));
	};

	static SetInstanceRotationVec3 = function (_instance, _rotation) {
		gml_pragma("forceinline");
		SetInstanceRotationX(_instance, _rotation.X);
		SetInstanceRotationY(_instance, _rotation.Y);
		SetInstanceRotationZ(_instance, _rotation.Z);
		return self;
	};

	static GetInstanceScaleVec3 = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstanceScaleX(_instance),
			GetInstanceScaleY(_instance),
			GetInstanceScaleZ(_instance));
	};

	static SetInstanceScaleVec3 = function (_instance, _scale) {
		gml_pragma("forceinline");
		SetInstanceScaleX(_instance, _scale.X);
		SetInstanceScaleY(_instance, _scale.Y);
		SetInstanceScaleZ(_instance, _scale.Z);
		return self;
	};

	/// @func select(_instance)
	/// @desc Adds an instance to selection.
	/// @param {Id.Instance} _instance The instance to select.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static select = function (_instance) {
		gml_pragma("forceinline");
		if (!is_selected(_instance))
		{
			ds_list_add(Selected, _instance);
		}
		return self;
	};

	/// @func is_selected(_instance)
	/// @desc Checks whether an instance is selected.
	/// @param {Id.Instance} _instance The instance to check.
	/// @return {Bool} Returns `true` if the instance is selected.
	static is_selected = function (_instance) {
		gml_pragma("forceinline");
		return (ds_list_find_index(Selected, _instance) != -1);
	};

	/// @func unselect(_instance)
	/// @desc Removes an instance from selection.
	/// @param {Id.Instance} _instance The instance to unselect.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static unselect = function (_instance) {
		gml_pragma("forceinline");
		var _index = ds_list_find_index(Selected, _instance);
		if (_index != -1)
		{
			ds_list_delete(Selected, _index);
		}
		return self;
	};

	/// @func toggle_select(_instance)
	/// @desc Unselects an instance if it's selected, or selects if it isn't.
	/// @param {Id.Instance} _instance The instance to toggle selection of.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static toggle_select = function (_instance) {
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

	/// @func clear_selection()
	/// @desc Removes all instances from selection.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static clear_selection = function () {
		gml_pragma("forceinline");
		ds_list_clear(Selected);
		return self;
	};

	/// @func unproject_vec2(_vector, _camera[, _renderer])
	/// @param {Struct.BBMOD_Vector2} _vector
	/// @param {Struct.BBMOD_Camera} _camera
	/// @param {Struct.BBMOD_Renderer/Undefined} [_renderer]
	/// @return {Struct.BBMOD_Vec3}
	/// @private
	static unproject_vec2 = function (_vector, _camera, _renderer=undefined) {
		var _forward = _camera.get_forward();
		var _up = _camera.get_up();
		var _right = _camera.get_right();
		var _tFov = dtan(_camera.Fov * 0.5);
		_up = _up.Scale(_tFov);
		_right = _right.Scale(_tFov * _camera.AspectRatio);
		var _screenWidth = _renderer ? _renderer.get_width() : window_get_width();
		var _screenHeight = _renderer ? _renderer.get_height() : window_get_height();
		var _screenX = _vector.X - (_renderer ? _renderer.X : 0);
		var _screenY = _vector.Y - (_renderer ? _renderer.Y : 0);
		var _ray = _forward.Add(_up.Scale(1.0 - 2.0 * (_screenY / _screenHeight))
			.Add(_right.Scale(2.0 * (_screenX / _screenWidth) - 1.0)));
		return _ray.Normalize();
	};

	/// @func intersect_ray_plane(_origin, _direction, _plane, _normal)
	/// @param {Struct.BBMOD_Vec3} _origin
	/// @param {Struct.BBMOD_Vec3} _direction
	/// @param {Struct.BBMOD_Vec3} _plane
	/// @param {Struct.BBMOD_Vec3} _normal
	/// @return {Struct.BBMOD_Vec3}
	/// @private
	static intersect_ray_plane = function (_origin, _direction, _plane, _normal) {
		var _t = -(_origin.Sub(_plane).Dot(_normal) / _direction.Dot(_normal));
		return _origin.Add(_direction.Scale(_t));
	};

	/// @func update(_deltaTime)
	/// @desc Updates the gizmo. Should be called every frame.
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static update = function (_deltaTime) {
		if (!IsEditing || !mouse_check_button(ButtonDrag))
		{
			if (keyboard_check_pressed(KeyNextEditSpace))
			{
				if (++EditSpace >= BBMOD_EEditSpace.SIZE)
				{
					EditSpace = 0;
				}
			}

			var _size = ds_list_size(Selected);
			var _posX = 0.0;
			var _posY = 0.0;
			var _posZ = 0.0;

			for (var i = _size - 1; i >= 0; --i)
			{
				var _instance = Selected[| i];

				if (!InstanceExists(_instance))
				{
					ds_list_delete(Selected, i);
					--_size;
					continue;
				}

				_posX += GetInstancePositionX(_instance);
				_posY += GetInstancePositionY(_instance);
				_posZ += GetInstancePositionZ(_instance);
			}

			if (_size > 0)
			{
				_posX /= _size;
				_posY /= _size;
				_posZ /= _size;

				Position.Set(_posX, _posY, _posZ);

				if (EditSpace == BBMOD_EEditSpace.Local)
				{
					var _lastSelected = Selected[| _size - 1];
					Rotation.Set(
						GetInstanceRotationX(_lastSelected),
						GetInstanceRotationY(_lastSelected),
						GetInstanceRotationZ(_lastSelected));
				}
				else
				{
					Rotation.Set(0.0, 0.0, 0.0);
				}
			}

			IsEditing = false;
			MouseOffset = undefined;
			MouseLockAt = undefined;
			PositionBackup = undefined;
			if (CursorBackup != undefined)
			{
				window_set_cursor(CursorBackup);
				CursorBackup = undefined;
			}

			return self;
		}

		var _mouseX = window_mouse_get_x();
		var _mouseY = window_mouse_get_y();

		if (!MouseLockAt)
		{
			MouseLockAt = new BBMOD_Vec2(_mouseX, _mouseY);
			CursorBackup = window_get_cursor();
		}

		var _quaternion = new BBMOD_Quaternion().FromEuler(Rotation.X, Rotation.Y, Rotation.Z);
		var _forward = _quaternion.Rotate(BBMOD_VEC3_FORWARD);
		var _right = _quaternion.Rotate(BBMOD_VEC3_RIGHT);
		var _up = _quaternion.Rotate(BBMOD_VEC3_UP);
		var _move = new BBMOD_Vec3();
		var _rotate = new BBMOD_Vec3();
		var _scale = new BBMOD_Vec3();

		switch (EditType)
		{
		case BBMOD_EEditType.Position:
			if (!PositionBackup)
			{
				PositionBackup = Position.Clone();
			}

			var _planeNormal = (EditAxis == BBMOD_EEditAxis.Z) ? _forward : _up;
			var _mouseWorld = intersect_ray_plane(
				global.__bbmodCameraCurrent.Position,
				unproject_vec2(new BBMOD_Vec2(_mouseX, _mouseY), global.__bbmodCameraCurrent),
				PositionBackup,
				_planeNormal);

			if (!MouseOffset)
			{
				MouseOffset = Position.Sub(_mouseWorld);
			}

			var _diff = _mouseWorld.Add(MouseOffset).Sub(Position);

			if (EditAxis & BBMOD_EEditAxis.X)
			{
				_move = _move.Add(_diff.Mul(_forward.Abs()));
			}

			if (EditAxis & BBMOD_EEditAxis.Y)
			{
				_move = _move.Add(_diff.Mul(_right.Abs()));
			}

			if (EditAxis & BBMOD_EEditAxis.Z)
			{
				_move = _move.Add(_diff.Mul(_up.Abs()));
			}
			break;

		case BBMOD_EEditType.Rotation:
			var _planeNormal = ((EditAxis == BBMOD_EEditAxis.X) ? _forward
				: ((EditAxis == BBMOD_EEditAxis.Y) ? _right
				: _up));
			var _mouseWorld = intersect_ray_plane(
				global.__bbmodCameraCurrent.Position,
				unproject_vec2(new BBMOD_Vec2(_mouseX, _mouseY), global.__bbmodCameraCurrent),
				Position,
				_planeNormal);

			if (!MouseOffset)
			{
				MouseOffset = _mouseWorld;
			}

			var _mul = (keyboard_check(KeyEditFaster) ? 2.0
				: (keyboard_check(KeyEditSlower) ? 0.1
				: 1.0));

			var _diff = _mouseWorld.Sub(MouseOffset).Scale(_mul);

			switch (EditAxis)
			{
			case BBMOD_EEditAxis.X:
				_rotate.X += (abs(_diff.Y) > abs(_diff.Z)) ? _diff.Y : -_diff.Z;
				break;

			case BBMOD_EEditAxis.Y:
				_rotate.Y += (abs(_diff.X) > abs(_diff.Z)) ? -_diff.X : -_diff.Z;
				break;

			case BBMOD_EEditAxis.Z:
				_rotate.Z += (abs(_diff.X) > abs(_diff.Y)) ? -_diff.X : _diff.Y;
				break;
			}

			window_mouse_set(MouseLockAt.X, MouseLockAt.Y);
			window_set_cursor(cr_none);
			break;

		case BBMOD_EEditType.Scale:
			var _planeNormal = (EditAxis == BBMOD_EEditAxis.Z) ? _forward : _up;
			var _mouseWorld = intersect_ray_plane(
				global.__bbmodCameraCurrent.Position,
				unproject_vec2(new BBMOD_Vec2(_mouseX, _mouseY), global.__bbmodCameraCurrent),
				Position,
				_planeNormal);

			if (!MouseOffset)
			{
				MouseOffset = _mouseWorld;
			}

			var _mul = (keyboard_check(KeyEditFaster) ? 5.0
				: (keyboard_check(KeyEditSlower) ? 0.1
				: 1.0));

			var _diff = _mouseWorld.Sub(MouseOffset).Scale(_mul);

			if (EditAxis == BBMOD_EEditAxis.All)
			{
				var _diffX = _diff.Mul(_forward.Abs()).Dot(_forward);
				var _diffY = _diff.Mul(_right.Abs()).Dot(_right);
				var _scaleBy = (abs(_diffX) > abs(_diffY)) ? _diffX : _diffY;
				_scale.X += _scaleBy;
				_scale.Y += _scaleBy;
				_scale.Z += _scaleBy;
			}
			else
			{
				if (EditAxis & BBMOD_EEditAxis.X)
				{
					_scale.X += _diff.Mul(_forward.Abs()).Dot(_forward);
				}

				if (EditAxis & BBMOD_EEditAxis.Y)
				{
					_scale.Y += _diff.Mul(_right.Abs()).Dot(_right);
				}

				if (EditAxis & BBMOD_EEditAxis.Z)
				{
					_scale.Z += _diff.Mul(_up.Abs()).Dot(_up);
				}
			}

			window_mouse_set(MouseLockAt.X, MouseLockAt.Y);
			window_set_cursor(cr_none);
			break;
		}

		var _size = ds_list_size(Selected);

		for (var i = _size - 1; i >= 0; --i)
		{
			var _instance = Selected[| i];

			if (!InstanceExists(_instance))
			{
				ds_list_delete(Selected, i);
				--_size;
				continue;
			}

			var _positionNew = GetInstancePositionVec3(_instance);
			_positionNew = _positionNew.Add(_move);
			SetInstancePositionVec3(_instance, _positionNew);

			var _quaternionLocal = new BBMOD_Quaternion().FromEuler(
				GetInstanceRotationX(_instance),
				GetInstanceRotationY(_instance),
				GetInstanceRotationZ(_instance));
			var _forwardLocal = _quaternionLocal.Rotate(BBMOD_VEC3_FORWARD);
			var _rightLocal = _quaternionLocal.Rotate(BBMOD_VEC3_RIGHT);
			var _upLocal = _quaternionLocal.Rotate(BBMOD_VEC3_UP);

			var _rotMatrix = new BBMOD_Matrix().RotateEuler(GetInstanceRotationVec3(_instance));
			if (_rotate.X != 0.0)
			{
				_rotMatrix = _rotMatrix.RotateQuat(new BBMOD_Quaternion().FromAxisAngle(_forward, _rotate.X));
			}
			if (_rotate.Y != 0.0)
			{
				_rotMatrix = _rotMatrix.RotateQuat(new BBMOD_Quaternion().FromAxisAngle(_right, _rotate.Y));
			}
			if (_rotate.Z != 0.0)
			{
				_rotMatrix = _rotMatrix.RotateQuat(new BBMOD_Quaternion().FromAxisAngle(_up, _rotate.Z));
			}
			var _rotArray = _rotMatrix.ToEuler();
			SetInstanceRotationX(_instance, _rotArray[0]);
			SetInstanceRotationY(_instance, _rotArray[1]);
			SetInstanceRotationZ(_instance, _rotArray[2]);

			var _scaleNew = GetInstanceScaleVec3(_instance)
			// Scale on X
			_scaleNew.X += _scale.X * abs(_forward.Dot(_forwardLocal));
			_scaleNew.Y += _scale.X * abs(_forward.Dot(_rightLocal));
			_scaleNew.Z += _scale.X * abs(_forward.Dot(_upLocal));
			// Scale on Y
			_scaleNew.X += _scale.Y * abs(_right.Dot(_forwardLocal));
			_scaleNew.Y += _scale.Y * abs(_right.Dot(_rightLocal));
			_scaleNew.Z += _scale.Y * abs(_right.Dot(_upLocal));
			// Scale on Z
			_scaleNew.X += _scale.Z * abs(_up.Dot(_forwardLocal));
			_scaleNew.Y += _scale.Z * abs(_up.Dot(_rightLocal));
			_scaleNew.Z += _scale.Z * abs(_up.Dot(_upLocal));
			SetInstanceScaleVec3(_instance, _scaleNew);
		}

		Position = Position.Add(_move);
		return self;
	};

	/// @func submit([_materials])
	/// @desc Immediately submits the gizmo for rendering.
	/// @param {Array<Struct.BBMOD_Material>/Undefined} [_materials] Materials to use.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	/// @note This changes the world matrix based on the gizmo's position and size!
	static submit = function (_materials=undefined) {
		gml_pragma("forceinline");
		new BBMOD_Matrix()
			.Scale(new BBMOD_Vec3(Size))
			.RotateEuler(Rotation)
			.Translate(Position)
			.ApplyWorld();
		Model.submit(_materials);
		return self;
	};

	/// @func render([_materials])
	/// @desc Enqueues the gizmo for rendering.
	/// @param {Array<Struct.BBMOD_Material>/Undefined} [_materials] Materials to use.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	/// @note This changes the world matrix based on the gizmo's position and size!
	static render = function (_materials=undefined) {
		gml_pragma("forceinline");
		new BBMOD_Matrix()
			.Scale(new BBMOD_Vec3(Size))
			.RotateEuler(Rotation)
			.Translate(Position)
			.ApplyWorld();
		Model.render(_materials);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		ds_list_destroy(Selected);
		return undefined;
	};
}