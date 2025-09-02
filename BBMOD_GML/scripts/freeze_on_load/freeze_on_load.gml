/// @func freeze_on_load(_error, _model)
///
/// @desc Freezes a model when its loaded.
///
/// @param {Struct.BBMOD_Exception, Undefined} _error
/// @param {Struct.BBMOD_Model, Undefined} _model
function freeze_on_load(_error, _model)
{
	bbmod_assert(_error == undefined);
	_model.freeze();
}
