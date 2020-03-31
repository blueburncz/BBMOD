/// @func bbmod_render(bbmod, materials)
/// @desc Submits a BBMOD for rendering.
/// @param {array} bbmod The BBMOD structure.
/// @param {array} materials An array of Material structures, one for each
/// material slot of the BBMOD.
gml_pragma("forceinline");
bbmod_node_render(argument0, argument0[@ BBMOD_EModel.RootNode], argument1);