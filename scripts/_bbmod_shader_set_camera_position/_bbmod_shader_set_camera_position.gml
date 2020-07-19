/// @func _bbmod_shader_set_camera_position(shader, camera_position)
/// @param {real} shader
/// @param {array} camera_position
var _shader = argument[0];
var _camera_position = (argument_count > 1) ? argument[1] : global.bbmod_camera_position;

shader_set_uniform_f_array(shader_get_uniform(_shader, "u_vCamPos"),
	_camera_position);