/// @func bbmod_set_bone_rotation(animation_player, bone_id, quaternion)
/// @desc Defines a bone rotation to be used instead of one from the animation
/// that's currently playing.
/// @param {array} animation_player The animation player structure.
/// @param {real} bone_id The id of the bone to transform.
/// @param {array/undefined} quaternion An array with the new bone rotation `[x,y,z,w]`,
/// or `undefined` to disable the override.
/// @note This should be used before [bbmod_animation_player_update](./bbmod_animation_player_update.html)
/// is executed.
gml_pragma("forceinline");
var _overrides = argument0[BBMOD_EAnimationPlayer.BoneRotationOverride];
_overrides[@ argument1] = argument2;