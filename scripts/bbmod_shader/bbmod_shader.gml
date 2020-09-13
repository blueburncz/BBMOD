/// @var {real[]} The current `[x,y,z]` position of the camera. This should be
/// updated every frame before rendering models, otherwise the default PBR
/// shaders won't work properly!
/// @see bbmod_set_camera_position
global.bbmod_camera_position = [0, 0, 0];

/// @var {real} The current camera exposure.
global.bbmod_camera_exposure = 0.1;

/// @var {ptr} The texture that is currently used for IBL.
/// @private
global.__bbmod_ibl_texture = pointer_null;

/// @var {ptr} A texel size of the IBL texture.
/// @private
global.__bbmod_ibl_texel = 0;

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
	var _ibl = shader_get_sampler_index(_shader, "u_texIBL");
	texture_set_stage(_ibl, _texture);
	gpu_set_tex_max_mip_ext(_ibl, mip_off);

	var _brdf = shader_get_sampler_index(_shader, "u_texBRDF");
	texture_set_stage(_brdf, sprite_get_texture(BBMOD_SprEnvBRDF, 0));
	gpu_set_tex_max_mip_ext(_brdf, mip_off);

	shader_set_uniform_f(shader_get_uniform(_shader, "u_vIBLTexel"),
		_texel, _texel);
}

/// @func _bbmod_shader_set_alpha_test(_shader, _alpha_test)
/// @param {shader} _shader
/// @param {real} _alpha_test
/// @private
function _bbmod_shader_set_alpha_test(_shader, _alpha_test)
{
	shader_set_uniform_f(shader_get_uniform(_shader, "u_fAlphaTest"),
		_alpha_test);
}

/// @func bbmod_set_camera_position(_x, _y, _z)
/// @desc Changes camera position to given coordinates.
/// @param {real} _x The x position of the camera.
/// @param {real} _y The y position of the camera.
/// @param {real} _z The z position of the camera.
/// @see global.bbmod_camera_position
function bbmod_set_camera_position(_x, _y, _z)
{
	gml_pragma("forceinline");
	var _position = global.bbmod_camera_position;
	_position[@ 0] = _x;
	_position[@ 1] = _y;
	_position[@ 2] = _z;
}

/// @func bbmod_set_ibl_sprite(_sprite, _subimage)
/// @desc Changes a texture used for image based lighting using a sprite.
/// @param {real} _sprite The sprite index.
/// @param {real} _subimage The sprite subimage to use.
/// @note This texture must be a stripe of eight prefiltered octahedrons, the
/// first seven being used for specular lighting and the last one for diffuse
/// lighting.
function bbmod_set_ibl_sprite(_sprite, _subimage)
{
	gml_pragma("forceinline");
	var _texel = 1 / sprite_get_height(_sprite);
	bbmod_set_ibl_texture(sprite_get_texture(_sprite, _subimage), _texel);
}

/// @func bbmod_set_ibl_texture(_texture, _texel)
/// @desc Changes a texture used for image based lighting.
/// @param {ptr} _texture The texture.
/// @param {real} _texel The size of a texel.
/// @note This texture must be a stripe of eight prefiltered octahedrons, the
/// first seven being used for specular lighting and the last one for diffuse
/// lighting.
function bbmod_set_ibl_texture(_texture, _texel)
{
	global.__bbmod_ibl_texture = _texture;
	global.__bbmod_ibl_texel = _texel;

	if (_texture != pointer_null)
	{
		var _material = global.__bbmod_material_current;
		if (_material != BBMOD_NONE)
		{
			var _shader = _material.Shader;
			_bbmod_shader_set_ibl(_shader, _texture, _texel);
		}
	}
}

// FIXME: Initial IBL setup
global.__bbmod_material_current = BBMOD_NONE;
var _spr_ibl = sprite_add("BBMOD/Skies/NoonIBL.png", 0, false, true, 0, 0);
bbmod_set_ibl_sprite(_spr_ibl, 0);