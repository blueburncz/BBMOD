/// @macro {Struct.BBMOD_PBRMaterial} A material for rendering RGBM encoded skies.
/// @see BBMOD_PBRMaterial
#macro BBMOD_MATERIAL_SKY __bbmod_material_sky()

/// @func bbmod_set_ibl_sprite(_sprite, _subimage)
/// @desc Changes a texture used for image based lighting using a sprite.
/// @param {Resource.GMSprite} _sprite The sprite index.
/// @param {Real} _subimage The sprite subimage to use.
/// @note This texture must be a stripe of eight prefiltered octahedrons, the
/// first seven being used for specular lighting and the last one for diffuse
/// lighting.
/// @deprecated Please use {@link bbmod_ibl_set} instead.
function bbmod_set_ibl_sprite(_sprite, _subimage)
{
	gml_pragma("forceinline");
	var _texel = 1 / sprite_get_height(_sprite);
	bbmod_set_ibl_texture(sprite_get_texture(_sprite, _subimage), _texel);
}

/// @func bbmod_set_ibl_texture(_texture, _texel)
/// @desc Changes a texture used for image based lighting.
/// @param {Pointer.Texture} _texture The texture.
/// @param {Real} _texel The size of a texel.
/// @note This texture must be a stripe of eight prefiltered octahedrons, the
/// first seven being used for specular lighting and the last one for diffuse
/// lighting.
/// @deprecated Please use {@link bbmod_ibl_set} instead.
function bbmod_set_ibl_texture(_texture, _texel)
{
	gml_pragma("forceinline");
	if (_texture != pointer_null)
	{
		global.__bbmodImageBasedLight = new BBMOD_ImageBasedLight(_texture);
	}
	else
	{
		global.__bbmodImageBasedLight = undefined;
	}
}