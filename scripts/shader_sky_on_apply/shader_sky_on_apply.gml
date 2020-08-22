/// @func shader_sky_on_apply(_material)
/// @desc The default material application function.
/// @param {array} _material The Material struct.
function shader_sky_on_apply(_material)
{
	var _shader = _material[BBMOD_EMaterial.Shader];
	_bbmod_shader_set_exposure(_shader);
}