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

	/// @var {Array<Struct.BBMOD_Material>}
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