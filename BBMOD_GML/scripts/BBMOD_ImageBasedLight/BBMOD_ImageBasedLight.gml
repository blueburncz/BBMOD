/// @func BBMOD_ImageBasedLight(_texture)
/// @extends BBMOD_Light
/// @desc An image based light.
/// @param {Pointer.Texture} _texture A texture containing 8 prefiltered
/// RGBM-encoded octahedrons, where the first 7 are for specular reflections
/// with increasing roughness and the last one is for diffuse lighting.
function BBMOD_ImageBasedLight(_texture)
	: BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Pointer.Texture} The texture of the IBL.
	/// @readonly
	Texture = _texture;

	/// @var {Real} The texel height of the texture.
	/// @readonly
	Texel = texture_get_texel_height(Texture);
}