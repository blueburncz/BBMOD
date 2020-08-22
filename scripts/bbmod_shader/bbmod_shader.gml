/// @func _bbmod_shader_set_camera_position(_shader, _camera_position)
/// @param {real} _shader
/// @param {array} _camera_position
function _bbmod_shader_set_camera_position()
{
	var _shader = argument[0];
	var _camera_position = (argument_count > 1) ? argument[1] : global.bbmod_camera_position;

	shader_set_uniform_f_array(shader_get_uniform(_shader, "u_vCamPos"),
		_camera_position);
}

/// @func _bbmod_shader_set_dynamic_batch_data(_shader, _data)
/// @param {real} _shader
/// @param {array} _data
function _bbmod_shader_set_dynamic_batch_data(_shader, _data)
{
	gml_pragma("forceinline");
	shader_set_uniform_f_array(shader_get_uniform(_shader, "u_vData"), _data);
}

/// @func _bbmod_shader_set_exposure(_shader[, _exposure])
/// @param {real} _shader
/// @param {real} [_exposure]
function _bbmod_shader_set_exposure()
{
	var _shader = argument[0];
	var _exposure = (argument_count > 1) ? argument[1] : global.bbmod_camera_exposure;

	shader_set_uniform_f(shader_get_uniform(_shader, "u_fExposure"),
		_exposure);
}

/// @func _bbmod_shader_set_ibl(_shader, _texture, _texel)
/// @param {real} _shader
/// @param {ptr} _texture
/// @param {real} _texel
function _bbmod_shader_set_ibl(_shader, _texture, _texel)
{
	texture_set_stage(shader_get_sampler_index(_shader, "u_texIBL"),
		_texture);
	shader_set_uniform_f(shader_get_uniform(_shader, "u_vIBLTexel"),
		_texel, _texel);

	texture_set_stage(shader_get_sampler_index(_shader, "u_texBRDF"),
		sprite_get_texture(BBMOD_SprEnvBRDF, 0));
}