/// @module Terrain

/// @func BBMOD_TerrainLayer()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Describes a material of a single terrain layer. A layer can be
/// assigned to only one {@link BBMOD_Terrain}. The terrain destroys its layers
/// when it is destroyed.
///
/// @see BBMOD_Terrain.Layer
function BBMOD_TerrainLayer() constructor
{
	/// @var {Pointer.Texture} A texture with a base color in the RGB channels
	/// and opacity in the alpha channel.
	BaseOpacity = (-1 /*pointer_null*/ );

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	BaseOpacityFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_TerrainLayer.BaseOpacity}, or
	/// `undefined`. Takes precedence over the texture when defined.
	BaseOpacitySprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_TerrainLayer.BaseOpacitySprite} to use.
	BaseOpacitySubimage = 0;

	/// @var {Bool} Whether this layer owns
	/// {@link BBMOD_TerrainLayer.BaseOpacitySprite}.
	BaseOpacityOwned = false;

	/// @var {Pointer.Texture} A texture with tangent-space normals in the RGB
	/// channels and smoothness in the alpha channel or `undefined`.
	NormalSmoothness = sprite_get_texture(BBMOD_SprDefaultNormalW, 0);

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	NormalSmoothnessFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_TerrainLayer.NormalSmoothness}, or
	/// `undefined`. Takes precedence over the texture when defined.
	NormalSmoothnessSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_TerrainLayer.NormalSmoothnessSprite} to use.
	NormalSmoothnessSubimage = 0;

	/// @var {Bool} Whether this layer owns
	/// {@link BBMOD_TerrainLayer.NormalSmoothnessSprite}.
	NormalSmoothnessOwned = false;

	/// @var {Pointer.Texture} A texture with tangent-space normals in the RGB
	/// channels and roughness in the alpha channel or `undefined`.
	NormalRoughness = undefined;

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	NormalRoughnessFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_TerrainLayer.NormalRoughness}, or
	/// `undefined`. Takes precedence over the texture when defined.
	NormalRoughnessSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_TerrainLayer.NormalRoughnessSprite} to use.
	NormalRoughnessSubimage = 0;

	/// @var {Bool} Whether this layer owns
	/// {@link BBMOD_TerrainLayer.NormalRoughnessSprite}.
	NormalRoughnessOwned = false;

	static to_buffer = function (_buffer)
	{
		bbmod_texture_ref_to_buffer(_buffer, self, "BaseOpacity");
		bbmod_texture_ref_to_buffer(_buffer, self, "NormalSmoothness");
		bbmod_texture_ref_to_buffer(_buffer, self, "NormalRoughness");
		return self;
	};

	static from_buffer = function (_buffer)
	{
		bbmod_texture_ref_from_buffer(_buffer, self, "BaseOpacity");
		bbmod_texture_ref_from_buffer(_buffer, self, "NormalSmoothness");
		bbmod_texture_ref_from_buffer(_buffer, self, "NormalRoughness");
		return self;
	};

	/// @func destroy()
	///
	/// @desc Releases owned texture sprites and destroys this layer.
	///
	/// @return {Undefined} Always returns `undefined`.
	static destroy = function ()
	{
		bbmod_texture_ref_destroy(self, "BaseOpacity");
		bbmod_texture_ref_destroy(self, "NormalSmoothness");
		bbmod_texture_ref_destroy(self, "NormalRoughness");
		return undefined;
	};
}
