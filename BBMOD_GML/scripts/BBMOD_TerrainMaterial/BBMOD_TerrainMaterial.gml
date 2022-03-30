/// @func BBMOD_TerrainMaterialLayer()
function BBMOD_TerrainMaterialLayer() constructor
{
	/// @var {ptr}
	BaseOpacity = pointer_null;

	/// @var {ptr}
	NormalSmoothness = pointer_null;
}

/// @func BBMOD_TerrainMaterial(_shader)
/// @extends BBMOD_Material
/// @desc
/// @param {BBMOD_Shader} _shader
function BBMOD_TerrainMaterial(_shader)
	: BBMOD_Material(_shader) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {BBMOD_TerrainMaterialLayer[5]} An array of 5 terrain material
	/// layers. Use `undefined` for unused layers.
	Layers = array_create(5, undefined);

	/// @var {ptr} Splatmap texture.
	Splatmap = pointer_null;

	/// @var {BBMOD_Vec2} Controls texture repeat over the entire terrain (not
	/// a single patch).
	TextureScale = new BBMOD_Vec2(1.0);
}