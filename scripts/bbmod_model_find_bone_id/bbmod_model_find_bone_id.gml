/// @func bbmod_model_find_bone_id(model, bone_name[, bone])
/// @desc Seaches for a bone id assigned to given bone name.
/// @param {array} model The Model structure.
/// @param {string} bone_name The name of the Bone structure.
/// @param {array/undefined} [bone] The Bone structure to start searching from.
/// Use `undefined` to use the model's root bone. Defaults to `undefined`.
/// @return {real/BBMOD_NONE} The id of the bone on success or `BBMOD_NONE` on fail.
/// @note It is not recommened to use this script in release builds, because having
/// many of these lookups can slow down your game! You should instead use the
/// ids available from the `_log.txt` files, which are created during model
/// conversion.
var _model = argument[0];
var _bone_name = argument[1];
var _bone = (argument_count > 2) ? argument[2] : _model[BBMOD_EModel.Skeleton];

if (_bone[BBMOD_EBone.Name] == _bone_name)
{
	return _bone[BBMOD_EBone.Index];
}

var _children = _bone[BBMOD_EBone.Children];
var i/*:int*/= 0;

repeat (array_length_1d(_children))
{
	var _found = bbmod_model_find_bone_id(_model, _bone_name, _children[i++]);
	if (_found != BBMOD_NONE)
	{
		return _found;
	}
}

return BBMOD_NONE;