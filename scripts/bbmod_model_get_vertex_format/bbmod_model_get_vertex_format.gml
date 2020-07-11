/// @func bbmod_model_get_vertex_format(model[, ids])
/// @desc TODO
/// @param {array} model
/// @param {bool} [ids]
/// @return {real}
// FIXME
gml_pragma("forceinline");
var _model = argument[0];
return bbmod_get_vertex_format(
	_model[BBMOD_EModel.HasVertices],
	_model[BBMOD_EModel.HasNormals],
	_model[BBMOD_EModel.HasTextureCoords],
	_model[BBMOD_EModel.HasColors],
	_model[BBMOD_EModel.HasTangentW],
	false,
	(argument_count > 1) ? argument[1] : false);
