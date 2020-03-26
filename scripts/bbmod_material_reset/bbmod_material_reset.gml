/// @func bbmod_material_reset()
gml_pragma("forceinline");
if (global.__bbmod_material_current != undefined)
{
	shader_reset();
	global.__bbmod_material_current = undefined;
}