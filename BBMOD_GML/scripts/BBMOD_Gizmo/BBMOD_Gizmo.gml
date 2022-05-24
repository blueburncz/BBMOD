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
///
/// @extends BBMOD_Class
///
/// @desc A gizmo for transforming instances.
///
/// @param {Real} [_size] The size of the gizmo. Default value is 10 units.
///
/// @note This requries synchronnous loading of models, therefore it cannot
/// be used on platforms like HTML5, which require asynchronnous loading.
/// You also **must** use {@link BBMOD_Camera} for the gizmo to work properly!
function BBMOD_Gizmo(_size=10.0)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Array<Struct.BBMOD_Model>} The gizmo model.
	/// @note Please note that this model is not loaded asynchronnously,
	/// therefore it cannot be used on platforms that require asynchronnous
	/// loading, like HTML5!
	/// @readonly
	/// @obsolete This has been replaced with {@link BBMOD_Gizmo.Models}.
	static Model = undefined;

	/// @var {Array<Struct.BBMOD_Model>} Gizmo models for individual edit modes.
	/// @note Please note that these are not loaded asynchronnously, therefore
	/// the gizmo cannot be used on platforms that require asynchronnous loading,
	/// like HTML5!
	/// @see BBMOD_EEditType
	/// @readonly
	static Models = undefined;

	/// @var {Array<Struct.BBMOD_Material>} Materials used when mouse-picking
	/// the gizmo.
	static MaterialsSelect = undefined;

	if (Models == undefined)
	{
		var _shaderSelect = new BBMOD_BaseShader(BBMOD_ShGizmoSelect, BBMOD_VFORMAT_DEFAULT);
		var _materialSelect = new BBMOD_BaseMaterial(_shaderSelect);
		_materialSelect.BaseOpacity = sprite_get_texture(BBMOD_SprGizmo, 1);
		MaterialsSelect = [_materialSelect];

		var _shader = new BBMOD_BaseShader(BBMOD_ShGizmo, BBMOD_VFORMAT_DEFAULT);
		var _material = new BBMOD_BaseMaterial(_shader);
		_material.BaseOpacity = sprite_get_texture(BBMOD_SprGizmo, 0);

		var _modelMove = new BBMOD_Model("Data/BBMOD/Models/GizmoMove.bbmod")
		_modelMove.Materials[0] = _material;

		var _modelScale = new BBMOD_Model("Data/BBMOD/Models/GizmoScale.bbmod")
		_modelScale.Materials[0] = _material;

		var _modelRotate = new BBMOD_Model("Data/BBMOD/Models/GizmoRotate.bbmod")
		_modelRotate.Materials[0] = _material;

		Models = [
			_modelMove,
			_modelRotate,
			_modelScale,
		];
	}

	/// @var {Bool} Used to show/hide the gizmo. Default value is `true`, which
	/// makes it visible.
	/// @obsolete This has been replaced with {@link BBMOD_Renderer.EditMode}.
	Visible = true;

	/// @var {Bool} If `true` then the gizmo is editing selected instances.
	IsEditing = false;

	/// @var {Struct.BBMOD_Vec2/Undefined} Screen-space coordinates to lock the
	/// mouse cursor at.
	/// @private
	MouseLockAt = undefined;

	/// @var {Struct.BBMOD_Vec3/Undefined} World-space offset from the mouse to
	/// the gizmo.
	/// @private
	MouseOffset = undefined;

	/// @var {Constant.Cursor} The cursor used before editing started.
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

	/// @var {Constant.MouseButton} The mouse button used for dragging the gizmo.
	ButtonDrag = mb_left;

	/// @var {Constant.VirtualKey} The virtual key used to switch to the next
	/// edit type.
	/// @see BBMOD_Gizmo.EditType
	KeyNextEditType = vk_tab;

	/// @var {Constant.VirtualKey} The virtual key used to switch to the next
	/// edit space.
	/// @see BBMOD_Gizmo.EditSpace
	KeyNextEditSpace = vk_space;

	/// @var {Constant.VirtualKey} The virtual key used to increase
	/// speed of editing (e.g. rotate objects by a larger angle).
	KeyEditFaster = vk_shift;

	/// @var {Constant.VirtualKey} The virtual key used to decrease
	/// speed of editing (e.g. rotate objects by a smaller angle).
	KeyEditSlower = vk_control;

	/// @var {Real} The size of the gizmo. Default value is 10.
	Size = _size;

	/// @var {Struct.BBMOD_Vec3} The gizmo's position in world-space.
	/// @readonly
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3/Undefined} The gizmo's position in world-space
	/// before editing started.
	/// @private
	PositionBackup = undefined;

	/// @var {Struct.BBMOD_Vec3} The gizmo's rotation in euler angles.
	Rotation = new BBMOD_Vec3();

	/// @var {Id.DsList<Id.Instance>} A list of selected instances.
	/// @readonly
	Selected = ds_list_create();

	/// @var {Id.DsList<Struct>} A list of additional data required for editing
	/// instances, e.g. their original offset from the gizmo, rotation and scale.
	/// @private
	InstanceData = ds_list_create();

	/// @var {Struct.BBMOD_Vec3} The current scaling factor of selected instances.
	/// @private
	ScaleBy = new BBMOD_Vec3(0.0);

	/// @var {Struct.BBMOD_Vec3} The current euler angles we are rotating selected
	/// instances by.
	/// @private
	RotateBy = new BBMOD_Vec3(0.0);

	/// @var {Function} A function that the gizmo uses to check whether an instance
	/// exists. Must take the instance as the first argument and return a bool.
	/// Defaults a function that returns the result of `instance_exists`.
	InstanceExists = function (_instance) {
		gml_pragma("forceinline");
		return instance_exists(_instance);
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// position on the X axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's `x`
	/// variable.
	GetInstancePositionX = function (_instance) {
		gml_pragma("forceinline");
		return _instance.x;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// position on the X axis. Must take the instance as the first argument and
	/// its new position on the X axis as the second argument. Defaults to a
	/// function that assings the new position to the instance's `x` variable.
	SetInstancePositionX = function (_instance, _x) {
		gml_pragma("forceinline");
		_instance.x = _x;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// position on the Y axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's `y`
	/// variable.
	GetInstancePositionY = function (_instance) {
		gml_pragma("forceinline");
		return _instance.y;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// position on the Y axis. Must take the instance as the first argument and
	/// its new position on the Y axis as the second argument. Defaults to a
	/// function that assings the new position to the instance's `y` variable.
	SetInstancePositionY = function (_instance, _y) {
		gml_pragma("forceinline");
		_instance.y = _y;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// position on the Z axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's `z`
	/// variable.
	GetInstancePositionZ = function (_instance) {
		gml_pragma("forceinline");
		return _instance.z;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// position on the Z axis. Must take the instance as the first argument and
	/// its new position on the Z axis as the second argument. Defaults to a
	/// function that assings the new position to the instance's `Z` variable.
	SetInstancePositionZ = function (_instance, _z) {
		gml_pragma("forceinline");
		_instance.z = _z;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// rotation on the X axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that always returns 0.
	GetInstanceRotationX = function (_instance) {
		gml_pragma("forceinline");
		return 0.0;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// rotation on the X axis. Must take the instance as the first argument and
	/// its new rotation on the X axis as the second argument. Defaults to a
	/// function that does not do anything.
	SetInstanceRotationX = function (_instance, _x) {
		gml_pragma("forceinline");
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// rotation on the Y axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that always returns 0.
	GetInstanceRotationY = function (_instance) {
		gml_pragma("forceinline");
		return 0.0;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// rotation on the Y axis. Must take the instance as the first argument and
	/// its new rotation on the Y axis as the second argument. Defaults to a
	/// function that does not do anything.
	SetInstanceRotationY = function (_instance, _y) {
		gml_pragma("forceinline");
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// rotation on the Z axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's
	/// `image_angle` variable.
	GetInstanceRotationZ = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_angle;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// rotation on the Z axis. Must take the instance as the first argument and
	/// its new rotation on the Z axis as the second argument. Defaults to a
	/// function that assings the new rotation to the instance's `image_angle`
	/// variable.
	SetInstanceRotationZ = function (_instance, _z) {
		gml_pragma("forceinline");
		_instance.image_angle = _z;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// scale on the X axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's
	/// `image_xscale` variable.
	GetInstanceScaleX = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_xscale;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// scale on the X axis. Must take the instance as the first argument and
	/// its new scale on the X axis as the second argument. Defaults to a
	/// function that assings the new scale to the instance's `image_xscale`
	/// variable.
	SetInstanceScaleX = function (_instance, _x) {
		gml_pragma("forceinline");
		_instance.image_xscale = _x;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// scale on the Y axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's
	/// `image_yscale` variable.
	GetInstanceScaleY = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_yscale;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// scale on the Y axis. Must take the instance as the first argument and
	/// its new scale on the Y axis as the second argument. Defaults to a
	/// function that assings the new scale to the instance's `image_yscale`
	/// variable.
	SetInstanceScaleY = function (_instance, _y) {
		gml_pragma("forceinline");
		_instance.image_yscale = _y;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// scale on the Z axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that always returns 1.
	GetInstanceScaleZ = function (_instance) {
		gml_pragma("forceinline");
		return 1.0;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// scale on the Z axis. Must take the instance as the first argument and
	/// its new scale on the Z axis as the second argument. Defaults to a
	/// function that does not do anything.
	SetInstanceScaleZ = function (_instance, _z) {
		gml_pragma("forceinline");
	};

	/// @func get_instance_position_vec3(_instance)
	/// @desc Retrieves an instance's position as {@link BBMOD_Vec3}.
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @return {Struct.BBMOD_Vec3} The instance's position.
	static get_instance_position_vec3 = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstancePositionX(_instance),
			GetInstancePositionY(_instance),
			GetInstancePositionZ(_instance));
	};

	/// @func set_instance_position_vec3(_instance, _position)
	/// @desc Changes an instance's position using a {@link BBMOD_Vec3}.
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @param {Struct.BBMOD_Vec3} _position The new position of the instance.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static set_instance_position_vec3 = function (_instance, _position) {
		gml_pragma("forceinline");
		SetInstancePositionX(_instance, _position.X);
		SetInstancePositionY(_instance, _position.Y);
		SetInstancePositionZ(_instance, _position.Z);
		return self;
	};

	/// @func get_instance_rotation_vec3(_instance)
	/// @desc Retrieves an instance's rotation as {@link BBMOD_Vec3}.
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @return {Struct.BBMOD_Vec3} The instance's rotation in euler angles.
	static get_instance_rotation_vec3 = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstanceRotationX(_instance),
			GetInstanceRotationY(_instance),
			GetInstanceRotationZ(_instance));
	};

	/// @func set_instance_rotation_vec3(_instance, _rotation)
	/// @desc Changes an instance's rotation using a {@link BBMOD_Vec3}.
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @param {Struct.BBMOD_Vec3} _rotation The new rotation of the instance
	/// in euler angles.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static set_instance_rotation_vec3 = function (_instance, _rotation) {
		gml_pragma("forceinline");
		SetInstanceRotationX(_instance, _rotation.X);
		SetInstanceRotationY(_instance, _rotation.Y);
		SetInstanceRotationZ(_instance, _rotation.Z);
		return self;
	};

	/// @func get_instance_scale_vec3(_instance)
	/// @desc Retrieves an instance's scale as {@link BBMOD_Vec3}.
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @return {Struct.BBMOD_Vec3} The instance's scale.
	static get_instance_scale_vec3 = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstanceScaleX(_instance),
			GetInstanceScaleY(_instance),
			GetInstanceScaleZ(_instance));
	};

	/// @func set_instance_scale_vec3(_instance, _scale)
	/// @desc Changes an instance's scale using a {@link BBMOD_Vec3}.
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @param {Struct.BBMOD_Vec3} _rotation The new scale of the instance.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static set_instance_scale_vec3 = function (_instance, _scale) {
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
			ds_list_add(InstanceData, {
				Offset: new BBMOD_Vec3(),
				Rotation: new BBMOD_Vec3(),
				Scale: new BBMOD_Vec3(),
			});
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
			ds_list_delete(InstanceData, _index);
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
		ds_list_clear(InstanceData);
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

	/// @func update_position()
	/// @desc Updates the gizmo's position, based on its selected instances.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static update_position = function () {
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
				ds_list_delete(InstanceData, i);
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

		return self;
	};

	/// @func update(_deltaTime)
	/// @desc Updates the gizmo. Should be called every frame.
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	/// @note This requires you to use a {@link BBMOD_Camera} and it will not
	/// do anything if its [apply](./BBMOD_Camera.apply.html) method has not been
	/// called yet!
	static update = function (_deltaTime) {
		if (!global.__bbmodCameraCurrent)
		{
			return self;
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Not editing or finished editing
		//
		if (!IsEditing || !mouse_check_button(ButtonDrag))
		{
			if (keyboard_check_pressed(KeyNextEditType))
			{
				if (++EditType >= BBMOD_EEditType.SIZE)
				{
					EditType = 0;
				}
			}

			if (keyboard_check_pressed(KeyNextEditSpace))
			{
				if (++EditSpace >= BBMOD_EEditSpace.SIZE)
				{
					EditSpace = 0;
				}
			}

			// Compute gizmo's new position
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
					ds_list_delete(InstanceData, i);
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

			// Store instance data
			for (var i = _size - 1; i >= 0; --i)
			{
				var _instance = Selected[| i];
				var _data = InstanceData[| i];
				_data.Offset = get_instance_position_vec3(_instance).Sub(Position);
				_data.Rotation = get_instance_rotation_vec3(_instance);
				_data.Scale = get_instance_scale_vec3(_instance);
			}

			// Clear properties used when editing
			IsEditing = false;
			MouseOffset = undefined;
			MouseLockAt = undefined;
			PositionBackup = undefined;
			if (CursorBackup != undefined)
			{
				window_set_cursor(CursorBackup);
				CursorBackup = undefined;
			}
			ScaleBy = new BBMOD_Vec3(0.0);
			RotateBy = new BBMOD_Vec3(0.0);

			return self;
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Editing
		//
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

		////////////////////////////////////////////////////////////////////////
		// Handle editing
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
				Position = Position.Add(_diff.Mul(_forward.Abs()));
			}

			if (EditAxis & BBMOD_EEditAxis.Y)
			{
				Position = Position.Add(_diff.Mul(_right.Abs()));
			}

			if (EditAxis & BBMOD_EEditAxis.Z)
			{
				Position = Position.Add(_diff.Mul(_up.Abs()));
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
			var _v1 = MouseOffset.Sub(Position);
			var _v2 = _mouseWorld.Sub(Position);
			var _angle = darctan2(_v2.Cross(_v1).Dot(_planeNormal), _v1.Dot(_v2)) * _mul;

			switch (EditAxis)
			{
			case BBMOD_EEditAxis.X:
				RotateBy.X += _angle;
				break;

			case BBMOD_EEditAxis.Y:
				RotateBy.Y += _angle;
				break;

			case BBMOD_EEditAxis.Z:
				RotateBy.Z += _angle;
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
				ScaleBy.X += _scaleBy;
				ScaleBy.Y += _scaleBy;
				ScaleBy.Z += _scaleBy;
			}
			else
			{
				if (EditAxis & BBMOD_EEditAxis.X)
				{
					ScaleBy.X += _diff.Mul(_forward.Abs()).Dot(_forward);
				}

				if (EditAxis & BBMOD_EEditAxis.Y)
				{
					ScaleBy.Y += _diff.Mul(_right.Abs()).Dot(_right);
				}

				if (EditAxis & BBMOD_EEditAxis.Z)
				{
					ScaleBy.Z += _diff.Mul(_up.Abs()).Dot(_up);
				}
			}

			window_mouse_set(MouseLockAt.X, MouseLockAt.Y);
			window_set_cursor(cr_none);
			break;
		}

		////////////////////////////////////////////////////////////////////////
		// Apply to selected instances
		var _matRot = [
			_forward.X, _forward.Y, _forward.Z, 0.0,
			_right.X,   _right.Y,   _right.Z,   0.0,
			_up.X,      _up.Y,      _up.Z,      0.0,
			0.0,        0.0,        0.0,        1.0,
		];

		var _matRotInverse = [
			_forward.X, _right.X, _up.X, 0.0,
			_forward.Y, _right.Y, _up.Y, 0.0,
			_forward.Z, _right.Z, _up.Z, 0.0,
			0.0,        0.0,      0.0,   1.0,
		];

		var _size = ds_list_size(Selected);

		for (var i = _size - 1; i >= 0; --i)
		{
			var _instance = Selected[| i];

			if (!InstanceExists(_instance))
			{
				ds_list_delete(Selected, i);
				ds_list_delete(InstanceData, i);
				--_size;
				continue;
			}

			var _data = InstanceData[| i];
			var _positionOffset = _data.Offset;
			var _rotationStored = _data.Rotation;
			var _scaleStored = _data.Scale;

			// Get local basis
			var _quaternionLocal = new BBMOD_Quaternion().FromEuler(
				GetInstanceRotationX(_instance),
				GetInstanceRotationY(_instance),
				GetInstanceRotationZ(_instance));
			var _forwardLocal = _quaternionLocal.Rotate(BBMOD_VEC3_FORWARD);
			var _rightLocal = _quaternionLocal.Rotate(BBMOD_VEC3_RIGHT);
			var _upLocal = _quaternionLocal.Rotate(BBMOD_VEC3_UP);

			// Apply rotation
			var _rotMatrix = new BBMOD_Matrix().RotateEuler(_rotationStored);
			if (RotateBy.X != 0.0)
			{
				var _quaternionX = new BBMOD_Quaternion().FromAxisAngle(_forward, RotateBy.X);
				_positionOffset = _quaternionX.Rotate(_positionOffset);
				_rotMatrix = _rotMatrix.RotateQuat(_quaternionX);
			}
			if (RotateBy.Y != 0.0)
			{
				var _quaternionY = new BBMOD_Quaternion().FromAxisAngle(_right, RotateBy.Y);
				_positionOffset = _quaternionY.Rotate(_positionOffset);
				_rotMatrix = _rotMatrix.RotateQuat(_quaternionY);
			}
			if (RotateBy.Z != 0.0)
			{
				var _quaternionZ = new BBMOD_Quaternion().FromAxisAngle(_up, RotateBy.Z);
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
			_scaleNew.X += ScaleBy.X * abs(_forward.Dot(_forwardLocal));
			_scaleNew.Y += ScaleBy.X * abs(_forward.Dot(_rightLocal));
			_scaleNew.Z += ScaleBy.X * abs(_forward.Dot(_upLocal));

			// Scale on Y
			_scaleNew.X += ScaleBy.Y * abs(_right.Dot(_forwardLocal));
			_scaleNew.Y += ScaleBy.Y * abs(_right.Dot(_rightLocal));
			_scaleNew.Z += ScaleBy.Y * abs(_right.Dot(_upLocal));

			// Scale on Z
			_scaleNew.X += ScaleBy.Z * abs(_up.Dot(_forwardLocal));
			_scaleNew.Y += ScaleBy.Z * abs(_up.Dot(_rightLocal));
			_scaleNew.Z += ScaleBy.Z * abs(_up.Dot(_upLocal));

			// Scale offset
			var _vI = matrix_transform_vertex(_matRotInverse, _positionOffset.X, _positionOffset.Y, _positionOffset.Z);
			var _vIRot = matrix_transform_vertex(
				matrix_build(
					0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
					(1.0 / max(_scaleOld.X, 0.0001)) * (_scaleOld.X + ScaleBy.X),
					(1.0 / max(_scaleOld.Y, 0.0001)) * (_scaleOld.Y + ScaleBy.Y),
					(1.0 / max(_scaleOld.Z, 0.0001)) * (_scaleOld.Z + ScaleBy.Z)),
				_vI[0], _vI[1], _vI[2]);
			var _v = matrix_transform_vertex(_matRot, _vIRot[0], _vIRot[1], _vIRot[2]);

			// Apply scale and position
			set_instance_scale_vec3(_instance, _scaleNew);
			SetInstancePositionX(_instance, Position.X + _v[0]);
			SetInstancePositionY(_instance, Position.Y + _v[1]);
			SetInstancePositionZ(_instance, Position.Z + _v[2]);
		}

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
		Models[EditType].submit(_materials);
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
		Models[EditType].render(_materials);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		ds_list_destroy(Selected);
		ds_list_destroy(InstanceData);
		return undefined;
	};
}