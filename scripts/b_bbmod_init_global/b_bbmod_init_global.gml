/// @func b_bbmod_init_global()
gml_pragma("global", "b_bbmod_init_global()");

/// @var {real} Mapping of vertex format masks to existing vertex formats.
global.__b_vertex_formats = ds_map_create();

/// @var {real} The default material.
global.__b_material_default = b_bbmod_material_create();