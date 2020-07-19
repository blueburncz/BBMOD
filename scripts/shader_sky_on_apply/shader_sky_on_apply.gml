/// @func shader_sky_on_apply(material)
/// @desc The default material application function.
/// @param {array} material The Material struct.
var _material = argument0;
var _shader = _material[BBMOD_EMaterial.Shader];

_bbmod_shader_set_exposure(_shader);