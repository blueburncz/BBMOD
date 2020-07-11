/// @func bbmod_set_ibl_sprite(sprite, subimage)
/// @desc Changes a texture used for image based lighting using a sprite.
/// @param {real} sprite The sprite index.
/// @param {real} subimage The sprite subimage to use.
/// @note This texture must be a stripe of eight prefiltered octahedrons, the
/// first seven being used for specular lighting and the last one for diffuse
/// lighting.
var _sprite = argument0;
var _subimage = argument1;
var _texel = 1 / sprite_get_height(_sprite);

bbmod_set_ibl_texture(sprite_get_texture(_sprite, _subimage), _texel);