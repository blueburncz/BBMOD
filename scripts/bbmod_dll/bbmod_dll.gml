/// @macro {real} A code returned from the DLL on fail, when none of `BBMOD_ERR_`
/// is applicable.
#macro BBMOD_DLL_FAILURE -1

/// @macro {real} A code returned from the DLL  when a model is successfully
/// converted.
#macro BBMOD_DLL_SUCCESS 0

/// @macro {real} An error code returned from the DLL when model loading fails.
#macro BBMOD_DLL_ERR_LOAD_FAILED 1

/// @macro {real} An error code returned from the DLL  when model conversion
/// fails.
#macro BBMOD_DLL_ERR_CONVERSION_FAILED 2

/// @macro {real} An error code returned from the DLL  when converted model
/// is not saved.
#macro BBMOD_DLL_ERR_SAVE_FAILED 3

/// @function BBMOD_DLL([_dll])
/// @desc Loads a DLL which allows you to convert models into BBMOD.
/// @param {string} [_dll] The path to the DLL file. Defaults to "BBMOD.dll".
function BBMOD_DLL() constructor
{
	dll = (argument_count > 0) ? argument[0] : "BBMOD.dll";

	dll_get_left_handed = external_define(dll, "bbmod_dll_get_left_handed", dll_cdecl, ty_real, 0);

	dll_set_left_handed = external_define(dll, "bbmod_dll_set_left_handed", dll_cdecl, ty_real, 1, ty_real);

	dll_get_invert_winding = external_define(dll, "bbmod_dll_get_invert_winding", dll_cdecl, ty_real, 0);

	dll_set_invert_winding = external_define(dll, "bbmod_dll_set_invert_winding", dll_cdecl, ty_real, 1, ty_real);

	dll_get_disable_normal = external_define(dll, "bbmod_dll_get_disable_normal", dll_cdecl, ty_real, 0);

	dll_set_disable_normal = external_define(dll, "bbmod_dll_set_disable_normal", dll_cdecl, ty_real, 1, ty_real);

	dll_get_disable_uv = external_define(dll, "bbmod_dll_get_disable_uv", dll_cdecl, ty_real, 0);

	dll_set_disable_uv = external_define(dll, "bbmod_dll_set_disable_uv", dll_cdecl, ty_real, 1, ty_real);

	dll_get_disable_color = external_define(dll, "bbmod_dll_get_disable_color", dll_cdecl, ty_real, 0);

	dll_set_disable_color = external_define(dll, "bbmod_dll_set_disable_color", dll_cdecl, ty_real, 1, ty_real);

	dll_get_disable_tangent = external_define(dll, "bbmod_dll_get_disable_tangent", dll_cdecl, ty_real, 0);

	dll_set_disable_tangent = external_define(dll, "bbmod_dll_set_disable_tangent", dll_cdecl, ty_real, 1, ty_real);

	dll_get_disable_bone = external_define(dll, "bbmod_dll_get_disable_bone", dll_cdecl, ty_real, 0);

	dll_set_disable_bone = external_define(dll, "bbmod_dll_set_disable_bone", dll_cdecl, ty_real, 1, ty_real);

	dll_convert = external_define(dll, "bbmod_dll_convert", dll_cdecl, ty_real, 2, ty_string, ty_string);

	/// @func convert(_fin, _fout)
	/// @desc Converts a model into a BBMOD.
	/// @param {string} _fin Path to the original model.
	/// @param {string} _fout Path to the converted model.
	/// @throws {BBMOD_Error}
	static convert = function (_fin, _fout) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_convert, _fin, _fout);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_disable_bone()
	/// @return {bool}
	static get_disable_bone = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_disable_bone);
	};

	/// @func set_disable_bone(_disable)
	/// @param {bool} _disable
	/// @throws {BBMOD_Error}
	static set_disable_bone = function (_disable) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_disable_bone, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_disable_color()
	/// @return {bool}
	static get_disable_color = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_disable_color);
	};

	/// @func set_disable_color(_disable)
	/// @param {bool} _disable
	/// @throws {BBMOD_Error}
	static set_disable_color = function (_disable) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_disable_color, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_disable_normal()
	/// @return {bool}
	static get_disable_normal = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_disable_normal);
	};

	/// @func set_disable_normal(_disable)
	/// @param {bool} _disable
	/// @throws {BBMOD_Error}
	static set_disable_normal = function (_disable) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_disable_normal, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_disable_tangent()
	/// @return {bool}
	static get_disable_tangent = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_disable_tangent);
	};

	/// @func set_disable_tangent(_disable)
	/// @param {bool} _disable
	/// @throws {BBMOD_Error}
	static set_disable_tangent = function (_disable) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_disable_tangent, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_disable_uv()
	/// @return {bool}
	static get_disable_uv = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_disable_uv);
	};

	/// @func set_disable_uv(_disable)
	/// @param {bool} _disable
	/// @throws {BBMOD_Error}
	static set_disable_uv = function (_disable) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_disable_uv, _disable);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_invert_winding()
	/// @return {bool}
	static get_invert_winding = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_invert_winding);
	};

	/// @func set_invert_winding(_invert)
	/// @param {bool} _invert
	/// @throws {BBMOD_Error}
	static set_invert_winding = function (_invert) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_invert_winding, _invert);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func get_left_handed()
	/// @return {bool}
	static get_left_handed = function () {
		gml_pragma("forceinline");
		return external_call(dll_get_left_handed);
	};

	/// @func set_left_handed(_left_handed)
	/// @param {bool} _left_handed
	/// @throws {BBMOD_Error}
	static set_left_handed = function (_left_handed) {
		gml_pragma("forceinline");
		var _retval = external_call(dll_set_left_handed, _left_handed);
		if (_retval != BBMOD_DLL_SUCCESS)
		{
			throw new BBMOD_Error();
		}
	};

	/// @func destroy()
	/// @desc Frees memory used by the DLL.
	static destroy = function () {
		external_free(dll);
	};
}