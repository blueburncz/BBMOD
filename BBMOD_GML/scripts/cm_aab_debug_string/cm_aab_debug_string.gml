function cm_aab_debug_string(aab)
{
	return $"Axis-aligned box: Group: {CM_AAB_GROUP}, Pos: [{CM_AAB_X}, {CM_AAB_Y}, {CM_AAB_Z}], Size: [{2*CM_AAB_HALFX}, {2*CM_AAB_HALFY}, {2*CM_AAB_HALFZ}]";
}