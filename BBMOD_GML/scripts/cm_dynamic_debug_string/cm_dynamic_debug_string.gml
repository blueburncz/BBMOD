function cm_dynamic_debug_string(dynamic)
{
	return $"[Dynamic: Group: {CM_DYNAMIC_GROUP}, Matrix: {CM_DYNAMIC_M}, Scale: {CM_DYNAMIC_SCALE}, Moving: {CM_DYNAMIC_MOVING ? "true" : "false"}, \n    Child object: {cm_debug_string(CM_DYNAMIC_OBJECT)}]";
}