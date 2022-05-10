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
	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Enum.BBMOD_EEditType}
	EditType = BBMOD_EEditType.Position;

	/// @var {Enum.BBMOD_EEditAxis}
	/// @readonly
	EditAxis = BBMOD_EEditAxis.None;

	/// @var {Bool}
	/// @readonly
	IsEditing = false;

	/// @var {Real}
	Size = 10.0;

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

	/// @func draw([_camera])
	/// @desc
	/// @param {Struct.BBMOD_Camera/Undefined} [_camera]
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static draw = function (_camera=undefined) {
		var _x0, _y0;
		var _x1, _y1;
		var _x2, _y2;
		var _x3, _y3;

		if (_camera)
		{
			var _screenPosition;

			_screenPosition = _camera.world_to_screen(Position);
			if (!_screenPosition) return self;
			_x0 = _screenPosition.X;
			_y0 = _screenPosition.Y;

			_screenPosition = _camera.world_to_screen(Position.Add(new BBMOD_Vec3(Size, 0.0, 0.0)));
			if (!_screenPosition) return self;
			_x1 = _screenPosition.X;
			_y1 = _screenPosition.Y;

			_screenPosition = _camera.world_to_screen(Position.Add(new BBMOD_Vec3(0.0, Size, 0.0)));
			if (!_screenPosition) return self;
			_x2 = _screenPosition.X;
			_y2 = _screenPosition.Y;

			_screenPosition = _camera.world_to_screen(Position.Add(new BBMOD_Vec3(0.0, 0.0, Size)));
			if (!_screenPosition) return self;
			_x3 = _screenPosition.X;
			_y3 = _screenPosition.Y;
		}
		else
		{
			_x0 = Position.X;
			_y0 = Position.Y;

			_x1 = _x0 + Size;
			_y1 = _y0;

			_x2 = _x0;
			_y2 = _y0 + Size;

			_x3 = _x0;
			_y3 = _y0;
		}

		var _color = draw_get_color();
		draw_set_color(c_red);
		draw_arrow(_x0, _y0, _x1, _y1, 16);
		draw_set_color(c_lime);
		draw_arrow(_x0, _y0, _x2, _y2, 16);
		draw_set_color(c_blue);
		draw_arrow(_x0, _y0, _x3, _y3, 16);
		draw_set_color(_color);

		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		ds_list_destroy(Selected);
	};
}