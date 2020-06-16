/// @func bbmod_model_get_vertex_format(model)
/// @desc TODO
/// @param {array} model
/// @return {real}
gml_pragma("forceinline");
var _model = argument0;
return bbmod_get_vertex_format(
	_model[BBMOD_EModel.HasVertices],
	_model[BBMOD_EModel.HasNormals],
	_model[BBMOD_EModel.HasTextureCoords],
	_model[BBMOD_EModel.HasColors],
	_model[BBMOD_EModel.HasTangentW],
	false);