/// @macro {BBMOD_PBRMaterial} The default sky material.
/// @see BBMOD_PBRMaterial
#macro BBMOD_MATERIAL_SKY __bbmod_material_sky()

/// @var {ptr} The texture that is currently used for IBL.
/// @private
global.__bbmodIblTexture = pointer_null;

/// @var {real} A texel size of the IBL texture.
/// @private
global.__bbmodIblTexel = 0;

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
	global.__bbmodIblTexture = _texture;
	global.__bbmodIblTexel = _texel;
}