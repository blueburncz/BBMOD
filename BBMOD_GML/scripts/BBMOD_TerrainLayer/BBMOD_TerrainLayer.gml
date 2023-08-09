/// @func BBMOD_TerrainLayer()
///
/// @desc Describes a material of a single terrain layer.
///
/// @see BBMOD_Terrain.Layer
function BBMOD_TerrainLayer() constructor
{
	/// @var {Pointer.Texture} A texture with a base color in the RGB channels
	/// and opacity in the alpha channel.
	BaseOpacity = pointer_null;

	/// @var {Pointer.Texture} A texture with tangent-space normals in the RGB
	/// channels and smoothness in the alpha channel or `undefined`.
	NormalSmoothness = sprite_get_texture(BBMOD_SprDefaultNormalW, 0);

	/// @var {Pointer.Texture} A texture with tangent-space normals in the RGB
	/// channels and roughness in the alpha channel or `undefined`.
	NormalRoughness = undefined;
}
