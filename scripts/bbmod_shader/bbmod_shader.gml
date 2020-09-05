/// @func _bbmod_shader_set_camera_position(_shader[, _camera_position])
/// @param {shader} _shader
/// @param {real[]} [_camera_position]
/// @private
function _bbmod_shader_set_camera_position(_shader)
{
	var _camera_position = (argument_count > 1) ? argument[1] : global.bbmod_camera_position;
	shader_set_uniform_f_array(shader_get_uniform(_shader, "u_vCamPos"),
		_camera_position);
}

/// @func _bbmod_shader_set_dynamic_batch_data(_shader, _data)
/// @param {shader} _shader
/// @param {real[]} _data
/// @private
function _bbmod_shader_set_dynamic_batch_data(_shader, _data)
{
	gml_pragma("forceinline");
	shader_set_uniform_f_array(shader_get_uniform(_shader, "u_vData"), _data);
}

/// @func _bbmod_shader_set_exposure(_shader[, _exposure])
/// @param {shader} _shader
/// @param {real} [_exposure]
/// @private
function _bbmod_shader_set_exposure(_shader)
{
	var _exposure = (argument_count > 1) ? argument[1] : global.bbmod_camera_exposure;
	shader_set_uniform_f(shader_get_uniform(_shader, "u_fExposure"),
		_exposure);
}

/// @func _bbmod_shader_set_ibl(_shader, _texture, _texel)
/// @param {shader} _shader
/// @param {ptr} _texture
/// @param {real} _texel
/// @private
function _bbmod_shader_set_ibl(_shader, _texture, _texel)
{
	texture_set_stage(shader_get_sampler_index(_shader, "u_texIBL"),
		_texture);
	shader_set_uniform_f(shader_get_uniform(_shader, "u_vIBLTexel"),
		_texel, _texel);
	texture_set_stage(shader_get_sampler_index(_shader, "u_texBRDF"),
		sprite_get_texture(BBMOD_SprEnvBRDF, 0));
}