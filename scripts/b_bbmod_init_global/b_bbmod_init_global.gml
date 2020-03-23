/// @func b_bbmod_init_global()
/// @desc Global initialization script for the BBMOD library.
gml_pragma("global", "b_bbmod_init_global()");

/// @var {real} Mapping of vertex format masks to existing vertex formats.
global.__b_bbmod_vertex_formats = ds_map_create();

/// @var {real} The default material.
global.__b_bbmod_material_default = b_bbmod_material_create();

/// @var {array/undefined} The currently applied material.
global.__b_bbmod_material_current = undefined;

/// @var {real} A stack used when posing skeletons to avoid recursion.
global.__b_bbmod_anim_stack = ds_stack_create();