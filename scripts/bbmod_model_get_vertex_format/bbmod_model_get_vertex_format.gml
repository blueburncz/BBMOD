/// @func bbmod_model_get_vertex_format(model[, bones[, ids]])
/// @desc Retrieves a vertex format of a model.
/// @param {array} model The mode.
/// @param {bool} [bones] Use `false` to disable bones. Defaults to `true`.
/// @param {bool} [ids] Use `true` to force ids for dynamic batching. Defaults
/// to `false`.
/// @return {real} The vertex format.
gml_pragma("forceinline");
var _model = argument[0];
var _bones = (argument_count > 1) ? argument[1] : true;
var _ids = (argument_count > 2) ? argument[2] : false;
return bbmod_get_vertex_format(
	_model[BBMOD_EModel.HasVertices],
	_model[BBMOD_EModel.HasNormals],
	_model[BBMOD_EModel.HasTextureCoords],
	_model[BBMOD_EModel.HasColors],
	_model[BBMOD_EModel.HasTangentW],
	_bones ? _model[BBMOD_EModel.HasBones] : false,
	_ids);