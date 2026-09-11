/// @module Core

/// @var {Struct.BBMOD_ImageBasedLight}
/// @private
global.__bbmodImageBasedLight = undefined;

/// @func BBMOD_ImageBasedLight(_texture)
///
/// @extends BBMOD_Light
///
/// @desc An image based light.
///
/// @param {Pointer.Texture} _texture A texture containing 8 prefiltered
/// RGBM-encoded octahedrons, where the first 7 are for specular reflections
/// with increasing roughness and the last one is for diffuse lighting.
function BBMOD_ImageBasedLight(_texture): BBMOD_Light() constructor
{
	static Light_destroy = destroy;

	/// @var {Pointer.Texture} The texture of the IBL.
	/// @readonly
	Texture = _texture;

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	TextureFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_ImageBasedLight.Texture}, or `undefined`.
	/// Takes precedence over the texture when defined.
	TextureSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_ImageBasedLight.TextureSprite} to use.
	TextureSubimage = 0;

	/// @var {Bool} Whether this light owns
	/// {@link BBMOD_ImageBasedLight.TextureSprite}.
	TextureOwned = false;

	/// @var {Real} The texel height of the texture.
	/// @readonly
	Texel = texture_get_texel_height(bbmod_texture_ref_resolve(
		Texture, TextureSprite, TextureSubimage));

	static destroy = function ()
	{
		Light_destroy();
		bbmod_texture_ref_destroy(self, "Texture");
		return undefined;
	};
}

/// @func bbmod_ibl_get()
///
/// @desc Retrieves the image based light passed to shaders.
///
/// @return {Struct.BBMOD_ImageBasedLight} The image based light or `undefined`.
///
/// @see bbmod_ibl_set
function bbmod_ibl_get()
{
	gml_pragma("forceinline");
	return global.__bbmodImageBasedLight;
}

/// @func bbmod_ibl_set(_ibl)
///
/// @desc Defines the image based light passed to shaders.
///
/// @param {Struct.BBMOD_ImageBasedLight} _ibl The new image based light or
/// `undefined`.
///
/// @see bbmod_ibl_get
function bbmod_ibl_set(_ibl)
{
	gml_pragma("forceinline");
	global.__bbmodImageBasedLight = _ibl;
}
