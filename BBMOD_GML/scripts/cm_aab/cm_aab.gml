enum CM_AAB
{
	TYPE, 
	GROUP,
	X, 
	Y, 
	Z, 
	HALFXSIZE,
	HALFYSIZE,
	HALFZSIZE,
	NUM
}

#macro CM_AAB_BEGIN var aab = array_create(CM_AAB.NUM, CM_OBJECTS.AAB)
#macro CM_AAB_TYPE  aab[@ CM_AAB.TYPE]
#macro CM_AAB_GROUP aab[@ CM_AAB.GROUP]
#macro CM_AAB_X		aab[@ CM_AAB.X]
#macro CM_AAB_Y		aab[@ CM_AAB.Y]
#macro CM_AAB_Z		aab[@ CM_AAB.Z]
#macro CM_AAB_HALFX aab[@ CM_AAB.HALFXSIZE]
#macro CM_AAB_HALFY aab[@ CM_AAB.HALFYSIZE]
#macro CM_AAB_HALFZ aab[@ CM_AAB.HALFZSIZE]
#macro CM_AAB_END	return aab

function cm_aab(x, y, z, xsize, ysize, zsize, group = CM_GROUP_SOLID)
{
	CM_AAB_BEGIN;
	CM_AAB_GROUP = group;
	CM_AAB_X = x;
	CM_AAB_Y = y;
	CM_AAB_Z = z;
	CM_AAB_HALFX = xsize / 2;
	CM_AAB_HALFY = ysize / 2;
	CM_AAB_HALFZ = zsize / 2;
	CM_AAB_END;
}