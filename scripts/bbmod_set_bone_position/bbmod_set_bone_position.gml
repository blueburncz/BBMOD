/// @func bbmod_set_bone_position(animation_player, bone_id, position)
/// @desc Defines a bone position to be used instead of one from the animation
/// that's currently playing.
/// @param {array} animation_player The animation player structure.
/// @param {real} bone_id The id of the bone to transform.
/// @param {array/undefined} position An array with the new bone position `[x,y,z]`,
/// or `undefined` to disable the override.
/// @note This should be used before [bbmod_animation_player_update](./bbmod_animation_player_update.html)
/// is executed.
gml_pragma("forceinline");
var _overrides = argument0[BBMOD_EAnimationPlayer.BonePositionOverride];
_overrides[@ argument1] = argument2;