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

/// @var {Id.DsMap} Maps pick IDs assigned to scene nodes back to the node
/// struct, so mesh-click picking can select scene nodes.
/// @private
global.__bbmodSceneNodePickMap = ds_map_create();

/// @var {Real} Incrementing counter for unique scene node pick IDs. Starts at
/// a high value to avoid collision with GameMaker instance IDs.
/// @private
global.__bbmodSceneNodePickIdNext = 100000000;

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
