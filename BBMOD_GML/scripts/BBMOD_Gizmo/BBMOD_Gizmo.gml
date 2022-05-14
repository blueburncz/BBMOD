/// @enum
enum BBMOD_EEditAxis
{
	None = 0,
	X = $1,
	Y = $10,
	Z = $100,
	All = $111,
};

/// @enum
enum BBMOD_EEditType
{
	Position,
	Rotation,
	Scale,
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

	/// @var {Struct.BBMOD_Model}
	/// @readonly
	static Model = undefined;

	if (!Model)
	{
		var _matBase = BBMOD_MATERIAL_DEFAULT.clone();
		_matBase.set_normal_smoothness(BBMOD_VEC3_UP, 0.5);
		_matBase.set_specular_color(BBMOD_C_DKGRAY);
		_matBase.BaseOpacity = pointer_null;
		_matBase.Culling = cull_noculling;

		var _matAll = _matBase.clone();

		var _matX = _matBase.clone();
		_matX.BaseOpacityMultiplier = BBMOD_C_RED;

		var _matY = _matBase.clone();
		_matY.BaseOpacityMultiplier = BBMOD_C_LIME;

		var _matZ = _matBase.clone();
		_matZ.BaseOpacityMultiplier = BBMOD_C_BLUE;

		Model = new BBMOD_Model("Data/BBMOD/Models/Gizmo.bbmod")
		Model.Materials = [
			BBMOD_MATERIAL_DEFAULT,
			// All
			_matAll,
			// Move
			_matX,
			_matY,
			_matZ,
			// Rotate
			_matX,
			_matY,
			_matZ,
			// Scale
			_matX,
			_matY,
			_matZ,
		];
	}

	/// @var {Enum.BBMOD_EEditType}
	EditType = BBMOD_EEditType.Position;

	/// @var {Enum.BBMOD_EEditAxis}
	/// @readonly
	EditAxis = BBMOD_EEditAxis.None;

	/// @var {Bool}
	/// @readonly
	IsEditing = false;

	/// @var {Real}
	Size = 25.0;

	/// @var {Struct.BBMOD_Vec3}
	/// @readonly
	Position = new BBMOD_Vec3();

	/// @var {Id.DsList<Id.Instance>}
	/// @private
	Selected = ds_list_create();

	/// @func select(_instance)
	/// @desc
	/// @param {Id.Instance} _instance
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
	/// @desc
	/// @param {Id.Instance} _instance
	/// @return {Bool}
	static is_selected = function (_instance) {
		gml_pragma("forceinline");
		return (ds_list_find_index(Selected, _instance) != -1);
	};

	/// @func unselect(_instance)
	/// @desc
	/// @param {Id.Instance} _instance
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
	/// @desc
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static clear_selection = function () {
		gml_pragma("forceinline");
		ds_list_clear(Selected);
		return self;
	};

	/// @func update(_deltaTime)
	/// @desc
	/// @param {Real} _deltaTime
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static update = function (_deltaTime) {
		return self;
	};

	/// @func submit([_materials])
	/// @desc
	/// @param {Array<Struct.BBMOD_Material>/Undefined} [_materials]
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static submit = function (_materials=undefined) {
		gml_pragma("forceinline");
		new BBMOD_Matrix().Scale(new BBMOD_Vec3(Size)).Translate(Position).ApplyWorld();
		Model.submit(_materials);
		return self;
	};

	/// @func render([_materials])
	/// @desc
	/// @param {Array<Struct.BBMOD_Material>/Undefined} [_materials]
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static render = function (_materials=undefined) {
		gml_pragma("forceinline");
		new BBMOD_Matrix().Scale(new BBMOD_Vec3(Size)).Translate(Position).ApplyWorld();
		Model.render(_materials);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		ds_list_destroy(Selected);
		return undefined;
	};
}