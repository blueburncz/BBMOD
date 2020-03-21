/// @func b_bbmod_render(bbmod)
/// @desc Submits model to a shader for rendering.
/// @param {array} bbmod A model to render.
gml_pragma("forceinline");
b_bbmod_node_render(argument0, argument0[@ B_EBBMOD.RootNode]);