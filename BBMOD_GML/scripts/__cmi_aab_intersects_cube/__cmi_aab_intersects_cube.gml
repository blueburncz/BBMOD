function __cmi_aab_intersects_cube(aab, hsize, bX, bY, bZ) 
{
	if (abs(bX - CM_AAB_X) > hsize + CM_AAB_HALFX){return false;}
	if (abs(bY - CM_AAB_Y) > hsize + CM_AAB_HALFY){return false;}
	if (abs(bZ - CM_AAB_Z) > hsize + CM_AAB_HALFZ){return false;}
	return true;
}