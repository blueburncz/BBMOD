/// @func bbmod_render(bbmod, materials)
/// @desc Submits model to a shader for rendering.
/// @param {array} bbmod A model to render.
/// @param {array} materials An array of materials for each material slot
/// of the model.
gml_pragma("forceinline");
bbmod_node_render(argument0, argument0[@ BBMOD_EModel.RootNode], argument1);