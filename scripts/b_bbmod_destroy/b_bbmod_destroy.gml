/// @func b_bbmod_destroy(bbmod)
/// @param {array} bbmod
var _bbmod = argument0;

// Destroy animations
var _animations = _bbmod[B_EBBMOD.Animations];
var _anim = ds_map_find_first(_animations);
repeat (ds_map_size(_animations))
{
	b_bbmod_animation_destroy(_animations[? _anim]);
	_anim = ds_map_find_next(_animations, _anim);
}
ds_map_destroy(_animations);