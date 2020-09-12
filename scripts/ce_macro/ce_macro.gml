CE_PRAGMA_ONCE;

/// @macro {code} A macro which ensures that the code after it in a script /
/// object (not instance!) event is executed only once.
#macro CE_PRAGMA_ONCE \
	do \
	{ \
		if (!variable_global_exists("__ce_pragma_once")) \
		{ \
			global.__ce_pragma_once = ds_map_create(); \
		} \
		var __callstack__ = debug_get_callstack(); \
		var __current__ = __callstack__[0]; \
		if (ds_map_exists(global.__ce_pragma_once, __current__)) \
		{ \
			exit; \
		} \
		global.__ce_pragma_once[? __current__] = 1; \
	} \
	until (1)