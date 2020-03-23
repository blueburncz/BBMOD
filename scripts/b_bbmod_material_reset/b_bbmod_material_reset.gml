/// @func b_bbmod_material_reset()
gml_pragma("forceinline");
if (global.__b_bbmod_material_current != undefined)
{
	shader_reset();
	global.__b_bbmod_material_current = undefined;
}