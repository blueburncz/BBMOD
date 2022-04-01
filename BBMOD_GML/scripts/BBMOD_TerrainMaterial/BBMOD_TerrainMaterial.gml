/// @func BBMOD_TerrainMaterialLayer()
function BBMOD_TerrainMaterialLayer() constructor
{
	/// @var {Pointer.Texture}
	BaseOpacity = pointer_null;

	/// @var {Pointer.Texture}
	NormalSmoothness = pointer_null;
}

/// @func BBMOD_TerrainMaterial(_shader)
/// @extends BBMOD_Material
/// @desc
/// @param {Struct.BBMOD_Shader} _shader
function BBMOD_TerrainMaterial(_shader)
	: BBMOD_Material(_shader) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Array.Mixed} An array of 5 {@link BBMOD_TerrainMaterialLayer}s or
	/// `undefined` if the layer is not used.
	Layers = array_create(5, undefined);

	/// @var {Pointer.Texture} Splatmap texture.
	Splatmap = pointer_null;

	/// @var {Struct.BBMOD_Vec2} Controls texture repeat over the entire terrain
	/// (not a single patch).
	TextureScale = new BBMOD_Vec2(1.0);
}