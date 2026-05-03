/// @module Core

/// @var {Id.Instance}
/// @private
global.__bbmodInstanceID = 0;

/// @var {Array<Id.Instance>,Undefined}
/// @private
global.__bbmodInstanceIDBatch = undefined;

/// @var {Struct.BBMOD_DynamicBatch,Undefined}
/// @private
global.__bbmodDynamicBatchContext = undefined;

/// @func bbmod_set_instance_id(_id)
///
/// @desc Sets an instance ID for all subsequently rendered models.
///
/// @param {Id.Instance} _id The ID of the instance.
function bbmod_set_instance_id(_id)
{
	gml_pragma("forceinline");
	global.__bbmodInstanceID = _id;
}
