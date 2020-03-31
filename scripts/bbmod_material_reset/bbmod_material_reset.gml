/// @func bbmod_material_reset()
/// @desc Resets the current material to `undefined`.
gml_pragma("forceinline");
if (global.__bbmod_material_current != undefined)
{
	shader_reset();
	global.__bbmod_material_current = undefined;
}