/// @func bbmod_set_bone_rotation_euler(animation_player, bone_id, euler_rotation)
/// @desc Defines a bone rotation to be used instead of one from the animation
/// that's currently playing.
/// @param {array} animation_player The animation player structure.
/// @param {real} bone_id The id of the bone to transform.
/// @param {array/undefined} euler_rotation An array with the new bone rotation `[x,y,z]`,
/// or `undefined` to disable the override.
/// @note This should be used before [bbmod_animation_player_update](./bbmod_animation_player_update.html)
/// is executed.
gml_pragma("forceinline");
var _bone_q_rot = undefined;

if (argument_count > 2) {
	
	//Convert from Euler to Quaternion
	_bone_q_rot = [1.0, 0.0, 0.0, 0.0000001];
	
	ce_quaternion_multiply(_bone_q_rot,[dcos(argument2[0]/2), dsin(argument2[0]/2), 0, 0]); //X
	ce_quaternion_multiply(_bone_q_rot,[dcos(argument2[1]/2), 0, 0, dsin(argument2[1]/2)]); //Y
	ce_quaternion_multiply(_bone_q_rot,[dcos(argument2[2]/2), 0, dsin(argument2[2]/2), 0]); //Z
}

//Apply rotation
bbmod_set_bone_rotation(argument0,argument1,_bone_q_rot);