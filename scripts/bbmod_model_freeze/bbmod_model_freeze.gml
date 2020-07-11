/// @func bbmod_model_freeze(model)
/// @desc Freezes all vertex buffers used by a model. This should make its
/// rendering faster, but it disables creating new batches of the model.
/// @param {array} model The model to freeze.
gml_pragma("forceinline");
_bbmod_node_freeze(argument0[BBMOD_EModel.RootNode]);