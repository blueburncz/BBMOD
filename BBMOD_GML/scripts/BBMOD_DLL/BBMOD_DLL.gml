/// @macro {real} A code returned from the DLL on fail, when none of
/// `BBMOD_DLL_ERR_` is applicable.
/// @private
#macro BBMOD_DLL_FAILURE -1

/// @macro {real} A code returned from the DLL when a model is successfully
/// converted.
/// @private
#macro BBMOD_DLL_SUCCESS 0

/// @macro {real} An error code returned from the DLL when model loading fails.
/// @private
#macro BBMOD_DLL_ERR_LOAD_FAILED 1

/// @macro {real} An error code returned from the DLL when model conversion
/// fails.
/// @private
#macro BBMOD_DLL_ERR_CONVERSION_FAILED 2

/// @macro {real} An error code returned from the DLL when converted model
/// is not saved.
/// @private
#macro BBMOD_DLL_ERR_SAVE_FAILED 3

/// @func BBMOD_DLL([_path])
/// @extends BBMOD_Class
/// @desc Loads a DLL which allows you to convert models into BBMOD.
/// @param {string} [_path] The path to the DLL file. Defaults to
/// "Data/BBMOD/BBMOD.dll".
/// @throws {BBMOD_Exception} If the DLL file does not exist.
/// @example
/// ```gml
/// var _dll = new BBMOD_DLL();
/// _dll.set_gen_normal(BBMOD_NORMALS_FLAT);
/// _dll.convert("House.fbx", "House.bbmod");
/// _dll.destroy();
/// modHouse = new BBMOD_Model("House.bbmod");
/// ```
function BBMOD_DLL(_path="Data/BBMOD/BBMOD.dll")
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {string} Path to the DLL file.
	/// @readonly
	Path = _path;

	if (!file_exists(Path))
	{
		throw new BBMOD_Exception("File " + Path + " does not exist!");
	}

	/// @func convert(_fin, _fout)
	/// @desc Converts a model into a BBMOD.
	/// @param {string} _fin Path to the original model.
	/// @param {string} _fout Path to the converted model.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the model conversion fails.
	static convert = function (_fin, _fout) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_convert", dll_cdecl, ty_real, 2, ty_string, ty_string);
		var _retval = external_call(_fn, _fin, _fout);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_disable_bone()
	/// @desc Checks whether bones are disabled.
	/// @return {bool} If `true` then bones are disabled.
	/// @see BBMOD_DLL.set_disable_bone
	static get_disable_bone = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_disable_bone", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_disable_bone(_disable)
	/// @desc Enables/disables bones and animations. These are by default
	/// **enabled**.
	/// @param {bool} _disable `true` to disable.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_disable_bone
	static set_disable_bone = function (_disable) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_disable_bone", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_disable_color()
	/// @desc Checks whether vertex colors are disabled.
	/// @return {bool} If `true` then vertex colors are disabled.
	/// @see BBMOD_DLL.set_disable_color
	static get_disable_color = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_disable_color", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_disable_color(_disable)
	/// @desc Enables/disables vertex colors. Vertex colors are by default
	/// **disabled**. Changing this makes the model incompatible with the
	/// default shaders!
	/// @param {bool} _disable `true` to disable.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_disable_color
	static set_disable_color = function (_disable) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_disable_color", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_disable_normal()
	/// @desc Checks whether vertex normals are disabled.
	/// @return {bool} If `true` then vertex normals are disabled.
	/// @see BBMOD_DLL.set_disable_normal
	static get_disable_normal = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_disable_normal", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_disable_normal(_disable)
	/// @desc Enables/disables vertex normals. Vertex normals are by default
	/// **enabled**. Changing this makes the model incompatible with the default
	/// shaders!
	/// @param {bool} _disable `true` to disable.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_disable_normal
	static set_disable_normal = function (_disable) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_disable_normal", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_flip_normal()
	/// @desc Checks whether flipping vertex normals is enabled.
	/// @return {bool} Returns `true` if enabled.
	/// @see BBMOD_DLL.set_flip_normal
	static get_flip_normal = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_flip_normal", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_flip_normal(_flip)
	/// @desc Enables/disables flipping vertex normals. This is by default
	/// **disabled**.
	/// @param {bool} _flip `true` to enable.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_flip_normal
	static set_flip_normal = function (_flip) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_flip_normal", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _flip);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_gen_normal()
	/// @desc Checks whether generating normal vectors is enabled.
	/// @return {real} Returns one of the `BBMOD_NORMALS_*` macros.
	/// @see BBMOD_DLL.set_gen_normal
	/// @see BBMOD_NORMALS_NONE
	/// @see BBMOD_NORMALS_FLAT
	/// @see BBMOD_NORMALS_SMOOTH
	static get_gen_normal = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_gen_normal", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_gen_normal(_normals)
	/// @desc Configures generating normal vectors. This is by default
	/// set to {@link BBMOD_NORMALS_SMOOTH}. Vertex normals are required
	/// by the default shaders!
	/// @param {real} _normals Use one of the `BBMOD_NORMALS_*` macros.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_gen_normal
	/// @see BBMOD_NORMALS_NONE
	/// @see BBMOD_NORMALS_FLAT
	/// @see BBMOD_NORMALS_SMOOTH
	static set_gen_normal = function (_normals) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_gen_normal", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _normals);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_disable_tangent()
	/// @desc Checks whether tangent and bitangent vectors are disabled.
	/// @return {bool} If `true` then tangent and bitangent vectors are disabled.
	/// @see BBMOD_DLL.set_disable_tangent
	static get_disable_tangent = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_disable_tangent", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_disable_tangent(_disable)
	/// @desc Enables/disables tangent and bitangent vectors. These are by
	/// default **enabled**. Changing this makes the model incompatible with
	/// the default shaders!
	/// @param {bool} _disable `true` to disable tangent and bitangent vectors.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_disable_tangent
	static set_disable_tangent = function (_disable) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_disable_tangent", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_disable_uv()
	/// @desc Checks whether texture coordinates are disabled.
	/// @return {bool} If `true` then texture coordinates are disabled.
	/// @see BBMOD_DLL.set_disable_uv
	static get_disable_uv = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_disable_uv", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_disable_uv(_disable)
	/// @desc Enables/disables texture coordinates. Texture coordinates
	/// are by default **enabled**. Changing this makes the model incompatible
	/// with the default shaders!
	/// @param {bool} _disable `true` to disable texture coordinates.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_disable_uv
	static set_disable_uv = function (_disable) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_disable_uv", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_flip_uv_horizontally()
	/// @desc Checks whether flipping texture coordinates horizontally is
	/// enabled.
	/// @return {bool} Returns `true` if enabled.
	/// @see BBMOD_DLL.set_flip_uv_horizontally
	static get_flip_uv_horizontally = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_flip_uv_horizontally", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_flip_uv_horizontally(_flip)
	/// @desc Enables/disables flipping texture coordinates horizontally. This
	/// is by default **disabled**.
	/// @param {bool} _flip `true` to enable.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_flip_uv_horizontally
	static set_flip_uv_horizontally = function (_flip) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_flip_uv_horizontally", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _flip);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_flip_uv_vertically()
	/// @desc Checks whether flipping texture coordinates vertically is enabled.
	/// @return {bool} Returns `true` if enabled.
	/// @see BBMOD_DLL.set_flip_uv_vertically
	static get_flip_uv_vertically = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_flip_uv_vertically", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_flip_uv_vertically(_flip)
	/// @desc Enables/disables flipping texture coordinates vertically. This is
	/// by default **enabled**.
	/// @param {bool} _flip `true` to enable.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_flip_uv_vertically
	static set_flip_uv_vertically = function (_flip) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_flip_uv_vertically", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _flip);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_invert_winding()
	/// @desc Checks whether inverse vertex winding is enabled.
	/// @return {bool} If `true` then inverse vertex winding is enabled.
	/// @see BBMOD_DLL.set_invert_winding
	static get_invert_winding = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_invert_winding", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_invert_winding(_invert)
	/// @desc Enables/disables inverse vertex winding. This is by default
	/// **disabled**.
	/// @param {bool} _invert `true` to invert winding.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_invert_winding
	static set_invert_winding = function (_invert) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_invert_winding", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _invert);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_left_handed()
	/// @desc Checks whether conversion to left-handed coordinate system is
	/// enabled.
	/// @return {bool} If `true` then conversion to left-handed coordinate
	/// system is enabled.
	/// @see BBMOD_DLL.set_left_handed
	static get_left_handed = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_left_handed", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_left_handed(_leftHanded)
	/// @desc Enables/disables conversion to left-handed coordinate system.
	/// This is by default **enabled**.
	/// @param {bool} _leftHanded `true` to enable conversion to left-handed
	/// coordinate system.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_left_handed
	static set_left_handed = function (_leftHanded) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_left_handed", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _leftHanded);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_optimize_nodes()
	/// @desc Checks whether node optimization is enabled.
	/// @return {bool} If `true` then node optimization is enabled.
	/// @see BBMOD_DLL.set_optimize_nodes
	static get_optimize_nodes = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_optimize_nodes", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_optimize_nodes(_optimize)
	/// @desc Enable/disable node optimization. When enabled, multiple
	/// nodes (without bones, animations, ...) are joined into one.
	/// This is by default **enabled**.
	/// @param {bool} _optimize `true` to enable node optimization.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_optimize_nodes
	static set_optimize_nodes = function (_optimize) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_optimize_nodes", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _optimize);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_optimize_meshes()
	/// @desc Checks whether mesh optimization is enabled.
	/// @return {bool} If `true` then mesh optimization is enabled.
	/// @see BBMOD_DLL.set_optimize_meshes
	static get_optimize_meshes = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_optimize_meshes", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_optimize_meshes(_optimize)
	/// @desc Enables/disables mesh optimization. When enabled, multiple meshes
	/// with the same material are joined into one to reduce draw calls. This is
	/// by default **enabled**.
	/// @param {bool} _optimize `true` to enable mesh optimization.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_optimize_meshes
	static set_optimize_meshes = function (_optimize) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_optimize_meshes", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _optimize);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_optimize_materials()
	/// @desc Checks whether material optimization is enabled.
	/// @return {bool} If `true` then material optimization is enabled.
	/// @see BBMOD_DLL.set_optimize_materials
	static get_optimize_materials = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_optimize_materials", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_optimize_materials(_optimize)
	/// @desc Enables/disables material optimization. When enabled, redundant
	/// materials are joined into one and unused materials are removed.
	/// This is by default **enabled**.
	/// @param {bool} _optimize `true` to enable material optimization.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_optimize_materials
	static set_optimize_materials = function (_optimize) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_optimize_materials", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, _optimize);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_optimize_animations()
	/// @desc Retrieves the animation optimization level.
	/// @return {uint} The animation optimization level. See section
	/// [Animation optimization levels](./AnimationOptimizationLevels.html) for
	/// more info.
	/// @see BBMOD_DLL.set_optimize_animations
	static get_optimize_animations = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_optimize_animations", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_optimize_animations(_level)
	/// @desc Sets the animation optimization level.
	/// This is by default set to **0**.
	/// @param {uint} _level The new animation optimization level. See section
	/// [Animation optimization levels](./AnimationOptimizationLevels.html) for
	/// more info.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_optimize_animations
	static set_optimize_animations = function (_level) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_optimize_animations", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, clamp(_level, 0, 2));
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	/// @func get_sampling_rate()
	/// @desc Retrieves the animation samping rate (frames per second).
	/// @return {uint} The animation sampling rate.
	/// @see BBMOD_DLL.set_sampling_rate
	static get_sampling_rate = function () {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_get_sampling_rate", dll_cdecl, ty_real, 0);
		return external_call(_fn);
	};

	/// @func set_sampling_rate(_fps)
	/// @desc Sets the animation sampling rate (frames per second).
	/// This is by default set to **60**.
	/// @param {uint} _fps The new animation sampling rate.
	/// @return {BBMOD_DLL} Returns `self`.
	/// @throws {BBMOD_Exception} If the operation fails.
	/// @see BBMOD_DLL.get_sampling_rate
	static set_sampling_rate = function (_fps) {
		gml_pragma("forceinline");
		static _fn = external_define(Path, "bbmod_dll_set_sampling_rate", dll_cdecl, ty_real, 1, ty_real);
		var _retval = external_call(_fn, max(floor(_fps), 1));
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Exception();
		}
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		external_free(Path);
	};
}