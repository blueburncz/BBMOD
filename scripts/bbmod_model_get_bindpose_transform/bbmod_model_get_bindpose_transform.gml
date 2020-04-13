/// @func bbmod_model_get_bindpose_transform(model)
/// @desc Creates a transformation array with model's bindpose.
/// @param {array} model A Model structure.
/// @return {array} The created array.
var _model = argument0;
var _bone_count = _model[BBMOD_EModel.BoneCount];
var _transform = array_create(_bone_count * 16, 0);
var _matrix = matrix_build_identity();
for (var i = 0; i < _bone_count; ++i)
{
	array_copy(_transform, i * 16, _matrix, 0, 16);
}
return _transform;