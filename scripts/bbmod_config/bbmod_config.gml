/// @func bbmod_config()
/// @desc A configuration script of the BBMOD library.

/// @macro The default BBMOD material.
#macro BBMOD_MATERIAL_DEFAULT global.__bbmod_material_default

/// @macro A value returned when loading fails or to destroy an existing
/// model/animation.
#macro BBMOD_NONE undefined

/// @macro A mask used to tell that a model is rendered in a forward render
/// path.
#macro BBMOD_RENDER_FORWARD (1)

/// @macro A mask used to tell that a model is rendered in a deferred render
/// path.
#macro BBMOD_RENDER_DEFERRED (1 << 1)

/// @macro How many bites to shift to read/write a "has vertices" predicate
/// from/to a vertex format mask.
#macro BBMOD_VFORMAT_VERTEX 0

/// @macro How many bites to shift to read/write a "has normals" predicate
/// from/to a vertex format mask.
#macro BBMOD_VFORMAT_NORMAL 1

/// @macro How many bites to shift to read/write a "has texture coodrinates"
/// predicate from/to a vertex format mask.
#macro BBMOD_VFORMAT_TEXCOORD 2

/// @macro How many bites to shift to read/write a "has colors" predicate
/// from/to a vertex format mask.
#macro BBMOD_VFORMAT_COLOR 3

/// @macro How many bites to shift to read/write a "has tangent and bitangent
/// sign" predicate from/to a vertex format mask.
#macro BBMOD_VFORMAT_TANGENTW 4

/// @macro How many bites to shift to read/write a "has bone indices and vertex
/// weights" predicate from/to a vertex format mask.
#macro BBMOD_VFORMAT_BONES 5