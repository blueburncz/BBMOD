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

/// @func BBMOD_Gizmo()
/// @extends BBMOD_Class
/// @desc
function BBMOD_Gizmo()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Struct.BBMOD_Model} The gizmo model.
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
		MaterialsSelect = [_materialSelect];

		var _material = BBMOD_MATERIAL_DEFAULT.clone();
		_material.BaseOpacity = sprite_get_texture(BBMOD_SprGizmo, 0);
		_material.set_normal_smoothness(BBMOD_VEC3_UP, 0.5);
		_material.set_specular_color(BBMOD_C_DKGRAY);
		_material.Culling = cull_noculling;

		Model = new BBMOD_Model("Data/BBMOD/Models/Gizmo.bbmod")
		Model.Materials[0] = _material;
	}

	/// @var {Bool} Used to show/hide the gizmo. Default value is `true`, which
	/// it visible.
	Visible = true;

	/// @var {Bool} If `true` then the gizmo is editing selected instances.
	IsEditing = false;

	/// @var {Enum.BBMOD_EEditType} Determines how are the selected instances
	/// edited (translated/rotated/scaled).
	/// @see BBMOD_EEditType
	EditType = BBMOD_EEditType.Position;

	/// @var {Enum.BBMOD_EEditAxis} Determines on which axes are the selected
	/// instances edited.
	/// @see BBMOD_EEditAxis
	EditAxis = BBMOD_EEditAxis.None;

	/// @var {Real} The size of the gizmo. Default value is 20.
	Size = 20.0;

	/// @var {Struct.BBMOD_Vec3} The gizmo's position in world-space.
	/// @readonly
	Position = new BBMOD_Vec3();

	/// @var {Id.DsList<Id.Instance>} A list of selected instances.
	/// @readonly
	Selected = ds_list_create();

	static _getInstancePositionX = function (_instance) {
		gml_pragma("forceinline");
		return _instance.x;
	};

	/// @var {Function} A function that takes an instance ID and returns its
	/// position on the X axis. Defaults to a function that returns the
	/// instance's `x` variable.
	GetInstancePositionX = _getInstancePositionX;

	static _getInstancePositionY = function (_instance) {
		gml_pragma("forceinline");
		return _instance.y;
	};

	/// @var {Function} A function that takes an instance ID and returns its
	/// position on the Y axis. Defaults to a function that returns the
	/// instance's `y` variable.
	GetInstancePositionY = _getInstancePositionY;

	static _getInstancePositionZ = function (_instance) {
		gml_pragma("forceinline");
		return _instance.z;
	};

	// @var {Function} A function that takes an instance ID and returns its
	/// position on the Z axis. Defaults to a function that returns the
	/// instance's `z` variable.
	GetInstancePositionZ = _getInstancePositionZ;

	static _getInstancePropertyZero = function (_instance) {
		gml_pragma("forceinline");
		return 0.0;
	};

	/// @var {Function} A function that takes an instance ID and returns its
	/// rotation on the X axis. Defaults to a function that always returns 0.
	GetInstanceRotationX = _getInstancePropertyZero;

	/// @var {Function} A function that takes an instance ID and returns its
	/// rotation on the Y axis. Defaults to a function that always returns 0.
	GetInstanceRotationY = _getInstancePropertyZero;

	static _getInstanceRotationZ = function (_instance) {
		gml_pragma("forceinline");
		return _instance.direction;
	};

	/// @var {Function} A function that takes an instance ID and returns its
	/// rotation on the Z axis. Defaults to a function that returns the
	/// instance's `direction` variable.
	GetInstanceRotationZ = _getInstanceRotationZ;

	static _getInstanceScaleX = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_xscale;
	};

	/// @var {Function} A function that takes an instance ID and returns its
	/// scale on the X axis. Defaults to a function that returns the instance's
	/// `image_xscale` variable.
	GetInstanceScaleX = _getInstanceScaleX;

	static _getInstanceScaleY = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_yscale;
	};

	/// @var {Function} A function that takes an instance ID and returns its
	/// scale on the Y axis. Defaults to a function that returns the instance's
	/// `image_yscale` variable.
	GetInstanceScaleY = _getInstanceScaleY;

	static _getInstancePropertyOne = function (_instance) {
		gml_pragma("forceinline");
		return 1.0;
	};

	/// @var {Function} A function that takes an instance ID and returns its
	/// rotation on the Z axis. Defaults to a function that always returns 1.
	GetInstanceScaleZ = _getInstancePropertyOne;

	//////////////////////

	static _setInstancePositionX = function (_instance, _x) {
		gml_pragma("forceinline");
		_instance.x = _x;
	};

	/// @var {Function} A function that takes an instance ID and its new
	/// position on the X axis and changes its position. Defaults to a function
	/// that modifies the instance's `x` variable.
	SetInstancePositionX = _setInstancePositionX;

	static _setInstancePositionY = function (_instance, _y) {
		gml_pragma("forceinline");
		_instance.y = _y;
	};

	/// @var {Function} A function that takes an instance ID and its new
	/// position on the Y axis and changes its position. Defaults to a function
	/// that modifies the instance's `y` variable.
	SetInstancePositionY = _getInstancePositionY;

	static _setInstancePositionZ = function (_instance, _z) {
		gml_pragma("forceinline");
		_instance.z = _z;
	};

	/// @var {Function} A function that takes an instance ID and its new
	/// position on the Z axis and changes its position. Defaults to a function
	/// that modifies the instance's `z` variable.
	SetInstancePositionZ = _setInstancePositionZ;

	static _setInstancePropertyEmpty = function (_instance, _val) {
		gml_pragma("forceinline");
	};

	/// @var {Function} A function that takes an instance ID and its new
	/// rotation on the X axis and changes its rotation. Defaults to a function
	/// that does not do anything.
	SetInstanceRotationX = _setInstancePropertyEmpty;

	/// @var {Function} A function that takes an instance ID and its new
	/// rotation on the Y axis and changes its rotation. Defaults to a function
	/// that does not do anything.
	SetInstanceRotationY = _setInstancePropertyEmpty;

	static _setInstanceRotationZ = function (_instance, _z) {
		gml_pragma("forceinline");
		_instance.direction = _z;
	};

	/// @var {Function} A function that takes an instance ID and its new
	/// rotation on the Z axis and changes its rotation. Defaults to a function
	/// that modifies the instance's `direction` variable.
	SetInstanceRotationZ = _setInstanceRotationZ;

	static _setInstanceScaleX = function (_instance, _x) {
		gml_pragma("forceinline");
		_instance.image_xscale = _x;
	};

	/// @var {Function} A function that takes an instance ID and its new
	/// scale on the X axis and changes its scale. Defaults to a function
	/// that modifies the instance's `image_xscale` variable.
	SetInstanceScaleX = _setInstanceScaleX;

	static _setInstanceScaleY = function (_instance, _y) {
		gml_pragma("forceinline");
		_instance.image_yscale = _y;
	};

	/// @var {Function} A function that takes an instance ID and its new
	/// scale on the X axis and changes its scale. Defaults to a function
	/// that modifies the instance's `image_yscale` variable.
	SetInstanceScaleY = _setInstanceScaleY;

	/// @var {Function} A function that takes an instance ID and its new
	/// scale on the Z axis and changes its scale. Defaults to a function
	/// that does not do anything.
	SetInstanceScaleZ = _setInstancePropertyEmpty;

	/// @func get_instance_position(_instance)
	/// @desc Retrieves an instance's position as a vector.
	/// @param {Id.Instance} _instance The instance to get position of.
	/// @return {Struct.BBMOD_Vec3} The instance's position.
	/// @see BBMOD_Gizmo.GetInstancePositionX
	/// @see BBMOD_Gizmo.GetInstancePositionY
	/// @see BBMOD_Gizmo.GetInstancePositionZ
	static get_instance_position = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstancePositionX(_instance),
			GetInstancePositionY(_instance),
			GetInstancePositionZ(_instance));
	};

	/// @func get_instance_rotation(_instance)
	/// @desc Retrieves an instance's rotation as a vector of euler angles.
	/// @param {Id.Instance} _instance The instance to get rotation of.
	/// @return {Struct.BBMOD_Vec3} The instance's rotation.
	/// @see BBMOD_Gizmo.GetInstanceRotationX
	/// @see BBMOD_Gizmo.GetInstanceRotationY
	/// @see BBMOD_Gizmo.GetInstanceRotationZ
	static get_instance_rotation = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstanceRotationX(_instance),
			GetInstanceRotationY(_instance),
			GetInstanceRotationZ(_instance));
	};

	/// @func get_instance_scale(_instance)
	/// @desc Retrieves an instance's scale as a vector.
	/// @param {Id.Instance} _instance The instance to get scale of.
	/// @return {Struct.BBMOD_Vec3} The instance's scale.
	/// @see BBMOD_Gizmo.GetInstanceScaleX
	/// @see BBMOD_Gizmo.GetInstanceScaleY
	/// @see BBMOD_Gizmo.GetInstanceScaleZ
	static get_instance_scale = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstanceScaleX(_instance),
			GetInstanceScaleY(_instance),
			GetInstanceScaleZ(_instance));
	};

	/// @func set_instance_position(_instance, _position)
	/// @desc Changes an instance's position using a vector.
	/// @param {Id.Instance} _instance The instance to get position of.
	/// @param {Struct.BBMOD_Vec3} _position The new position.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	/// @see BBMOD_Gizmo.SetInstancePositionX
	/// @see BBMOD_Gizmo.SetInstancePositionY
	/// @see BBMOD_Gizmo.SetInstancePositionZ
	static set_instance_position = function (_instance, _position) {
		gml_pragma("forceinline");
		SetInstancePositionX(_instance, _position.X);
		SetInstancePositionX(_instance, _position.Y);
		SetInstancePositionX(_instance, _position.Z);
		return self;
	};

	/// @func set_instance_rotation(_instance, _rotation)
	/// @desc Changes an instance's rotation using a vector of euler angles.
	/// @param {Id.Instance} _instance The instance to get position of.
	/// @param {Struct.BBMOD_Vec3} _rotation The new rotation.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	/// @see BBMOD_Gizmo.SetInstancePositionX
	/// @see BBMOD_Gizmo.SetInstancePositionY
	/// @see BBMOD_Gizmo.SetInstancePositionZ
	static set_instance_rotation = function (_instance, _rotation) {
		gml_pragma("forceinline");
		SetInstanceRotationX(_instance, _rotation.X);
		SetInstanceRotationX(_instance, _rotation.Y);
		SetInstanceRotationX(_instance, _rotation.Z);
		return self;
	};

	/// @func set_instance_scale(_instance, _scale)
	/// @desc Changes an instance's scale using a vector.
	/// @param {Id.Instance} _instance The instance to get position of.
	/// @param {Struct.BBMOD_Vec3} _scale The new scale.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	/// @see BBMOD_Gizmo.SetInstanceScaleX
	/// @see BBMOD_Gizmo.SetInstanceScaleY
	/// @see BBMOD_Gizmo.SetInstanceScaleZ
	static set_instance_scale = function (_instance, _scale) {
		gml_pragma("forceinline");
		SetInstanceScaleX(_instance, _scale.X);
		SetInstanceScaleX(_instance, _scale.Y);
		SetInstanceScaleX(_instance, _scale.Z);
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

	/// @func clear_selection()
	/// @desc Removes all instances from selection.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static clear_selection = function () {
		gml_pragma("forceinline");
		ds_list_clear(Selected);
		return self;
	};

	/// @func update(_deltaTime)
	/// @desc Updates the gizmo.
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static update = function (_deltaTime) {
		return self;
	};

	/// @func submit([_materials])
	/// @desc Immediately submits the gizmo for rendering.
	/// @param {Array<Struct.BBMOD_Material>/Undefined} [_materials] Materials to use.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	/// @note If {@link BBMOD_Gizmo.Visible} is `false` then the gizmo is not submitted.
	/// This also changes the world matrix based on the gizmo's position and size!
	static submit = function (_materials=undefined) {
		gml_pragma("forceinline");
		if (Visible)
		{
			new BBMOD_Matrix().Scale(new BBMOD_Vec3(Size)).Translate(Position).ApplyWorld();
			Model.submit(_materials);
		}
		return self;
	};

	/// @func render([_materials])
	/// @desc Enqueues the gizmo for rendering.
	/// @param {Array<Struct.BBMOD_Material>/Undefined} [_materials] Materials to use.
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	/// @note If {@link BBMOD_Gizmo.Visible} is `false` then the gizmo is not submitted.
	/// This also changes the world matrix based on the gizmo's position and size!
	static render = function (_materials=undefined) {
		gml_pragma("forceinline");
		if (Visible)
		{
			new BBMOD_Matrix().Scale(new BBMOD_Vec3(Size)).Translate(Position).ApplyWorld();
			Model.render(_materials);
		}
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		ds_list_destroy(Selected);
		return undefined;
	};
}