/// @func shader_sky_on_apply(material)
/// @desc The default material application function.
/// @param {array} material The Material struct.
var _material = argument0;
var _shader = _material[BBMOD_EMaterial.Shader];

shader_set_uniform_f(shader_get_uniform(_shader, "u_fExposure"),
	exposure);