function cm_aab_get_aabb(aab)
{
	/*
			Returns the AABB of the shape as an array with six values
	*/
	return [CM_AAB_X - CM_AAB_HALFX,
			CM_AAB_Y - CM_AAB_HALFY,
			CM_AAB_Z - CM_AAB_HALFZ,
			CM_AAB_X + CM_AAB_HALFX,
			CM_AAB_Y + CM_AAB_HALFY,
			CM_AAB_Z + CM_AAB_HALFZ];
}