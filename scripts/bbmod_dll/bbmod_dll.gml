/// @macro {int} The supported version of BBMOD and BBANIM files.
#macro BBMOD_VERSION 2

/// @macro {real} A code returned from the DLL on fail, when none of `BBMOD_ERR_`
/// is applicable.
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

/// @macro {real} A value used to tell that no normals should be generated
/// if the model doesn't have any.
/// @see BBMOD_NORMALS_FLAT
/// @see BBMOD_NORMALS_SMOOTH
/// @see BBMOD_DLL.set_gen_normal
/// @see BBMOD_DLL.get_gen_normal
#macro BBMOD_NORMALS_NONE 0

/// @macro {real} A value used to tell that flat normals should be generated
/// if the model doesn't have any.
/// @see BBMOD_NORMALS_NONE
/// @see BBMOD_NORMALS_SMOOTH
/// @see BBMOD_DLL.set_gen_normal
/// @see BBMOD_DLL.get_gen_normal
#macro BBMOD_NORMALS_FLAT 1

/// @macro {real} A value used to tell that smooth normals should be generated
/// if the model doesn't have any.
/// @see BBMOD_NORMALS_NONE
/// @see BBMOD_NORMALS_FLAT
/// @see BBMOD_DLL.set_gen_normal
/// @see BBMOD_DLL.get_gen_normal
#macro BBMOD_NORMALS_SMOOTH 2

/// @func BBMOD_DLL([_path])
/// @desc Loads a DLL which allows you to convert models into BBMOD.
/// @param {string} [_path] The path to the DLL file. Defaults to "BBMOD/DLL/BBMOD.dll".
/// @throws {BBMOD_Error} If the DLL file does not exist.
/// @example
/// ```gml
/// var _dll = new BBMOD_DLL();
/// _dll.set_gen_normal(BBMOD_NORMALS_FLAT);
/// _dll.convert("House.fbx", "House.bbmod");
/// _dll.destroy();
/// mod_house = new BBMOD_Model("House.bbmod");
/// ```
function BBMOD_DLL() constructor
{
	/// @var {string} Path to the DLL file.
	/// @readonly
	path = (argument_count > 0) ? argument[0] : "BBMOD/BBMOD.dll";

	if (!file_exists(path))
	{
		throw new BBMOD_Error("File " + path + " does not exist!");
	}

	dll_get_left_handed = external_define(path, "bbmod_dll_get_left_handed", dll_cdecl, ty_real, 0);

	dll_set_left_handed = external_define(path, "bbmod_dll_set_left_handed", dll_cdecl, ty_real, 1, ty_real);

	dll_get_invert_winding = external_define(path, "bbmod_dll_get_invert_winding", dll_cdecl, ty_real, 0);

	dll_set_invert_winding = external_define(path, "bbmod_dll_set_invert_winding", dll_cdecl, ty_real, 1, ty_real);

	dll_get_disable_normal = external_define(path, "bbmod_dll_get_disable_normal", dll_cdecl, ty_real, 0);

	dll_set_disable_normal = external_define(path, "bbmod_dll_set_disable_normal", dll_cdecl, ty_real, 1, ty_real);

	dll_get_flip_normal = external_define(path, "bbmod_dll_get_flip_normal", dll_cdecl, ty_real, 0);

	dll_set_flip_normal = external_define(path, "bbmod_dll_set_flip_normal", dll_cdecl, ty_real, 1, ty_real);

	dll_get_gen_normal = external_define(path, "bbmod_dll_get_gen_normal", dll_cdecl, ty_real, 0);

	dll_set_gen_normal = external_define(path, "bbmod_dll_set_gen_normal", dll_cdecl, ty_real, 1, ty_real);

	dll_get_disable_uv = external_define(path, "bbmod_dll_get_disable_uv", dll_cdecl, ty_real, 0);

	dll_set_disable_uv = external_define(path, "bbmod_dll_set_disable_uv", dll_cdecl, ty_real, 1, ty_real);

	dll_get_flip_uv_horizontally = external_define(path, "bbmod_dll_get_flip_uv_horizontally", dll_cdecl, ty_real, 0);

	dll_set_flip_uv_horizontally = external_define(path, "bbmod_dll_set_flip_uv_horizontally", dll_cdecl, ty_real, 1, ty_real);

	dll_get_flip_uv_vertically = external_define(path, "bbmod_dll_get_flip_uv_vertically", dll_cdecl, ty_real, 0);

	dll_set_flip_uv_vertically = external_define(path, "bbmod_dll_set_flip_uv_vertically", dll_cdecl, ty_real, 1, ty_real);

	dll_get_disable_color = external_define(path, "bbmod_dll_get_disable_color", dll_cdecl, ty_real, 0);

	dll_set_disable_color = external_define(path, "bbmod_dll_set_disable_color", dll_cdecl, ty_real, 1, ty_real);

	dll_get_disable_tangent = external_define(path, "bbmod_dll_get_disable_tangent", dll_cdecl, ty_real, 0);

	dll_set_disable_tangent = external_define(path, "bbmod_dll_set_disable_tangent", dll_cdecl, ty_real, 1, ty_real);

	dll_get_disable_bone = external_define(path, "bbmod_dll_get_disable_bone", dll_cdecl, ty_real, 0);

	dll_set_disable_bone = external_define(path, "bbmod_dll_set_disable_bone", dll_cdecl, ty_real, 1, ty_real);

	dll_convert = external_define(path, "bbmod_dll_convert", dll_cdecl, ty_real, 2, ty_string, ty_string);

	/// @func convert(_fin, _fout)
	/// @desc Converts a model into a BBMOD.
	/// @param {string} _fin Path to the original model.
	/// @param {string} _fout Path to the converted model.
	/// @throws {BBMOD_Error} If the model conversion fails.
	static convert = function (_fin, _fout) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_convert, _fin, _fout);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_disable_bone()
	/// @desc Checks whether bones are disabled.
	/// @return {bool} `true` if bones are disabled.
	/// @see set_disable_bone
	static get_disable_bone = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_disable_bone);
	};

	/// @func set_disable_bone(_disable)
	/// @desc Enables/disables bones and animations. These are by default
	/// **enabled**.
	/// @param {bool} _disable `true` to disable.
	/// @throws {BBMOD_Error} If the operation fails.
	/// @see get_disable_bone
	static set_disable_bone = function (_disable) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_disable_bone, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_disable_color()
	/// @desc Checks whether vertex colors are disabled.
	/// @return {bool} `true` if vertex colors are disabled.
	/// @see set_disable_color
	static get_disable_color = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_disable_color);
	};

	/// @func set_disable_color(_disable)
	/// @desc Enables/disables vertex colors. Vertex colors are by default
	/// **disabled**. Changing this makes the model incompatible with the default
	/// shaders!
	/// @param {bool} _disable `true` to disable.
	/// @throws {BBMOD_Error} If the operation fails.
	/// @see get_disable_color
	static set_disable_color = function (_disable) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_disable_color, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_disable_normal()
	/// @desc Checks whether vertex normals are disabled.
	/// @return {bool} `true` if vertex normals are disabled.
	/// @see set_disable_normal
	static get_disable_normal = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_disable_normal);
	};

	/// @func set_disable_normal(_disable)
	/// @desc Enables/disables vertex normals. Vertex normals are by default
	/// **enabled**. Changing this makes the model incompatible with the default
	/// shaders!
	/// @param {bool} _disable `true` to disable.
	/// @throws {BBMOD_Error} If the operation fails.
	/// @see get_disable_normal
	static set_disable_normal = function (_disable) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_disable_normal, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_flip_normal()
	/// @desc Checks whether flipping vertex normals is enabled.
	/// @return {bool} Returns `true` if enabled.
	static get_flip_normal = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_flip_normal);
	};

	/// @func set_flip_normal(_flip)
	/// @desc Enables/disables flipping vertex normals. This is by default
	/// **disabled**.
	/// @param {bool} _flip `true` to enable.
	/// @throws {BBMOD_Error} If the operation fails.
	static set_flip_normal = function (_flip) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_flip_normal, _flip);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_gen_normal()
	/// @desc Checks whether generating normal vectors is enabled.
	/// @return {real} Returns one of the `BBMOD_NORMALS_*` macros.
	/// @see BBMOD_NORMALS_NONE
	/// @see BBMOD_NORMALS_FLAT
	/// @see BBMOD_NORMALS_SMOOTH
	static get_gen_normal = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_gen_normal);
	};

	/// @func set_gen_normal(_normals)
	/// @desc Configures generating normal vectors. This is by default
	/// set to {@link BBMOD_NORMALS_SMOOTH}. Vertex normals are required
	/// by the default shaders!
	/// @param {real} _normals Use one of the `BBMOD_NORMALS_*` macros.
	/// @throws {BBMOD_Error} If the operation fails.
	/// @see BBMOD_NORMALS_NONE
	/// @see BBMOD_NORMALS_FLAT
	/// @see BBMOD_NORMALS_SMOOTH
	static set_gen_normal = function (_normals) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_gen_normal, _normals);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_disable_tangent()
	/// @desc Checks whether tangent and bitangent vectors are disabled.
	/// @return {bool} `true` if tangent and bitangent vectors are disabled.
	/// @see set_disable_tangent
	static get_disable_tangent = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_disable_tangent);
	};

	/// @func set_disable_tangent(_disable)
	/// @desc Enables/disables tangent and bitangent vectors. These are by
	/// default **enabled**. Changing this makes the model incompatible with
	/// the default shaders!
	/// @param {bool} _disable `true` to disable tangent and bitangent vectors.
	/// @throws {BBMOD_Error} If the operation fails.
	/// @see get_disable_tangent
	static set_disable_tangent = function (_disable) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_disable_tangent, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_disable_uv()
	/// @desc Checks whether texture coordinates are disabled.
	/// @return {bool} `true` if texture coordinates are disabled.
	/// @see set_disable_uv
	static get_disable_uv = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_disable_uv);
	};

	/// @func set_disable_uv(_disable)
	/// @desc Enables/disables texture coordinates. Texture coordinates
	/// are by default **enabled**. Changing this makes the model incompatible
	/// with the default shaders!
	/// @param {bool} _disable `true` to disable texture coordinates.
	/// @throws {BBMOD_Error} If the operation fails.
	/// @see get_disable_uv
	static set_disable_uv = function (_disable) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_disable_uv, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_flip_uv_horizontally()
	/// @desc Checks whether flipping texture coordinates horizontally is enabled.
	/// @return {bool} Returns `true` if enabled.
	static get_flip_uv_horizontally = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_flip_uv_horizontally);
	};

	/// @func set_flip_uv_horizontally(_flip)
	/// @desc Enables/disables flipping texture coordinates horizontally. This is
	/// by default **disabled**.
	/// @param {bool} _flip `true` to enable.
	/// @throws {BBMOD_Error} If the operation fails.
	static set_flip_uv_horizontally = function (_flip) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_flip_uv_horizontally, _flip);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_flip_uv_vertically()
	/// @desc Checks whether flipping texture coordinates vertically is enabled.
	/// @return {bool} Returns `true` if enabled.
	static get_flip_uv_vertically = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_flip_uv_vertically);
	};

	/// @func set_flip_uv_vertically(_flip)
	/// @desc Enables/disables flipping texture coordinates vertically. This is
	/// by default **enabled**.
	/// @param {bool} _flip `true` to enable.
	/// @throws {BBMOD_Error} If the operation fails.
	static set_flip_uv_vertically = function (_flip) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_flip_uv_vertically, _flip);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_invert_winding()
	/// @desc Checks whether inverse vertex winding is enabled.
	/// @return {bool} `true` if inverse vertex winding is enabled.
	/// @see set_invert_winding
	static get_invert_winding = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_invert_winding);
	};

	/// @func set_invert_winding(_invert)
	/// @desc Enables/disables inverse vertex winding. This is by default
	/// **disabled**.
	/// @param {bool} _invert `true` to invert winding.
	/// @throws {BBMOD_Error} If the operation fails.
	/// @see get_invert_winding
	static set_invert_winding = function (_invert) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_invert_winding, _invert);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_left_handed()
	/// @desc Checks whether conversion to left-handed coordinate system is
	/// enabled.
	/// @return {bool} `true` if conversion to left-handed coordinate
	/// system is enabled.
	/// @see set_left_handed
	static get_left_handed = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_left_handed);
	};

	/// @func set_left_handed(_left_handed)
	/// @desc Enables/disables conversion to left-handed coordinate system.
	/// This is by default **enabled**.
	/// @param {bool} _left_handed `true` to enable conversion to left-handed
	/// coordinate system.
	/// @throws {BBMOD_Error} If the operation fails.
	/// @see get_left_handed
	static set_left_handed = function (_left_handed) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_left_handed, _left_handed);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func destroy()
	/// @desc Frees memory used by the DLL. Use this in combination with
	/// `delete` to destroy the struct.
	/// @example
	/// ```gml
	/// dll.destroy();
	/// delete dll;
	/// ```
	static destroy = function () {
		external_free(dll);
	};
}