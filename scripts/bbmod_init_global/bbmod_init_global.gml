/// @func bbmod_init_global()
/// @desc Global initialization script for the BBMOD library.
gml_pragma("global", "bbmod_init_global()");

/// @var {real} Mapping of vertex format masks to existing vertex formats.
global.__bbmod_vertex_formats = ds_map_create();

/// @var {real} The default material.
global.__bbmod_material_default = bbmod_material_create();

/// @var {array/undefined} The currently applied material.
global.__bbmod_material_current = undefined;

/// @var {real} A stack used when posing skeletons to avoid recursion.
global.__bbmod_anim_stack = ds_stack_create();