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

	/// @var {Enum.BBMOD_EEditType} Determines how are the selected instances
	/// edited (translated/rotated/scaled).
	/// @see BBMOD_EEditType
	EditType = BBMOD_EEditType.Position;

	/// @var {Enum.BBMOD_EEditAxis} Determines on which axes are the selected
	/// instances edited.
	/// @see BBMOD_EEditAxis
	EditAxis = BBMOD_EEditAxis.None;

	/// @var {Real} The size of the gizmo. Default value is 10.
	Size = _size;

	/// @var {Struct.BBMOD_Vec3} The gizmo's position in world-space.
	/// @readonly
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The gizmo's rotation in euler angles.
	Rotation = new BBMOD_Vec3();

	/// @var {Id.DsList<Id.Instance>} A list of selected instances.
	/// @readonly
	Selected = ds_list_create();

	InstanceExists = function (_instance) {
		gml_pragma("forceinline");
		return instance_exists(_instance);
	};

	GetInstancePosX = function (_instance) {
		gml_pragma("forceinline");
		return _instance.x;
	};

	SetInstancePosX = function (_instance, _x) {
		gml_pragma("forceinline");
		_instance.x = _x;
	};

	GetInstancePosY = function (_instance) {
		gml_pragma("forceinline");
		return _instance.y;
	};

	SetInstancePosY = function (_instance, _y) {
		gml_pragma("forceinline");
		_instance.y = _y;
	};

	GetInstancePosZ = function (_instance) {
		gml_pragma("forceinline");
		return _instance.z;
	};

	SetInstancePosZ = function (_instance, _z) {
		gml_pragma("forceinline");
		_instance.z = _z;
	};

	GetInstanceRotX = function (_instance) {
		gml_pragma("forceinline");
		return 0.0;
	};

	SetInstanceRotX = function (_instance, _x) {
		gml_pragma("forceinline");
	};

	GetInstanceRotY = function (_instance) {
		gml_pragma("forceinline");
		return 0.0;
	};

	SetInstanceRotY = function (_instance, _y) {
		gml_pragma("forceinline");
	};

	GetInstanceRotZ = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_angle;
	};

	SetInstanceRotZ = function (_instance, _z) {
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

	/// @func update(_deltaTime)
	/// @desc Updates the gizmo. Should be called every frame.
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static update = function (_deltaTime) {
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

			_posX += GetInstancePosX(_instance);
			_posY += GetInstancePosY(_instance);
			_posZ += GetInstancePosZ(_instance);
		}

		if (_size > 0)
		{
			_posX /= _size;
			_posY /= _size;
			_posZ /= _size;

			Position.Set(_posX, _posY, _posZ);

			// TODO: Do this only in local transform space!
			var _lastSelected = Selected[| _size - 1];

			Rotation.Set(
				GetInstanceRotX(_lastSelected),
				GetInstanceRotY(_lastSelected),
				GetInstanceRotZ(_lastSelected));
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