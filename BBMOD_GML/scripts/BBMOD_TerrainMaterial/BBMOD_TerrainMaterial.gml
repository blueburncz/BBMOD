/// @module Terrain

/// @func BBMOD_TerrainMaterial([_shader])
///
/// @extends BBMOD_BaseMaterial
///
/// @desc A material that can be used when rendering terrain.
///
/// @param {Struct.BBMOD_Shader} [_shader] A shader that the material uses in
/// the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you would
/// like to use {@link BBMOD_Material.set_shader} to specify shaders used in
/// specific render passes.
///
/// @see BBMOD_Shader
function BBMOD_TerrainMaterial(_shader = undefined): BBMOD_BaseMaterial(_shader) constructor
{
	static clone = function ()
	{
		var _clone = new BBMOD_TerrainMaterial();
		copy(_clone);
		return _clone;
	};
}
