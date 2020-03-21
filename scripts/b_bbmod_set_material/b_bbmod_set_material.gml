/// @func b_bbmod_set_material(bbmod, index, material)
/// @param {array} bbmod
/// @param {real} index
/// @param {array} material
gml_pragma("forceinline");
var _materials = argument0[B_EBBMOD.Materials];
_materials[@ argument1] = argument2;