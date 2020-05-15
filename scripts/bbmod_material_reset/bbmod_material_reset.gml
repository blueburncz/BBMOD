/// @func bbmod_material_reset()
/// @desc Resets the current material to `undefined`.
gml_pragma("forceinline");
if (global.__bbmod_material_current != undefined)
{
	shader_reset();
	gpu_pop_state();
	global.__bbmod_material_current = undefined;
}
else
{
	gpu_push_state();
}