/// @var {Id.Instance}
/// @private
global.__bbmodInstanceID = 0;

/// @func bbmod_set_instance_id(_id)
/// @desc
/// @param {Id.Instance} _id
function bbmod_set_instance_id(_id)
{
	gml_pragma("forceinline");
	global.__bbmodInstanceID = _id;
}