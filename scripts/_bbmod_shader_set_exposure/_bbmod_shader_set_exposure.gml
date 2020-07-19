/// @func _bbmod_shader_set_exposure(shader,[ exposure])
/// @param {real} shader
/// @param {real} [exposure]
var _shader = argument[0];
var _exposure = (argument_count > 1) ? argument[1] : global.bbmod_camera_exposure;

shader_set_uniform_f(shader_get_uniform(_shader, "u_fExposure"),
	_exposure);