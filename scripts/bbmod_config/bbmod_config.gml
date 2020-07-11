/// @func bbmod_config()
/// @desc A configuration script of the BBMOD library. Contains macro
/// definitions etc. See its content for more info.

/// @macro The default material.
#macro BBMOD_MATERIAL_DEFAULT global.__bbmod_material_default

/// @macro The default material for animated models.
#macro BBMOD_MATERIAL_DEFAULT_ANIMATED global.__bbmod_material_default_animated

/// @macro A value returned when loading fails or to destroy an existing
/// model/animation.
#macro BBMOD_NONE undefined

/// @macro {string} An event triggered on animation end. The event data
/// will containg the animation that was finished playing.
#macro BBMOD_EV_ANIMATION_END "bbmod_ev_animation_end"

/// @macro A flag used to tell that a model is rendered in a forward render
/// path.
#macro BBMOD_RENDER_FORWARD (1)

/// @macro A flag used to tell that a model is rendered in a deferred render
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

/// @macro How many bites to shift to read/write a "has ids for dynamic batching"
/// predicate from/to a vertex format mask.
#macro BBMOD_VFORMAT_IDS 6

/// @macro An index of the last found AnimationKey, updated by
/// [bbmod_find_animation_key](./bbmod_find_animation_key.html).
#macro BBMOD_KEY_INDEX_LAST global.__bbmod_key_index_last