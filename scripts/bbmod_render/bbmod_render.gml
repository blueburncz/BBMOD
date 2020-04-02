/// @func bbmod_render(bbmod, materials[, animation_instance])
/// @desc Submits a BBMOD for rendering.
/// @param {array} bbmod The BBMOD structure.
/// @param {array} materials An array of Material structures, one for each
/// material slot of the BBMOD.
/// @param {array/undefined} animation_instance An AnimationInstance structure or
/// `undefined`.
gml_pragma("forceinline");
bbmod_node_render(
	argument[0],
	array_get(argument[0], BBMOD_EModel.RootNode),
	argument[1],
	(argument_count > 2) ? argument[2] : undefined);