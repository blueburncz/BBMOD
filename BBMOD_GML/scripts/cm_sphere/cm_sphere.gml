enum CM_SPHERE
{
	TYPE, 
	GROUP,
	X, 
	Y, 
	Z, 
	R, 
	NUM
}

#macro CM_SPHERE_BEGIN	var sphere = array_create(CM_SPHERE.NUM, CM_OBJECTS.SPHERE)
#macro CM_SPHERE_TYPE	sphere[@ CM_SPHERE.TYPE]
#macro CM_SPHERE_GROUP	sphere[@ CM_SPHERE.GROUP]
#macro CM_SPHERE_X		sphere[@ CM_SPHERE.X]
#macro CM_SPHERE_Y		sphere[@ CM_SPHERE.Y]
#macro CM_SPHERE_Z		sphere[@ CM_SPHERE.Z]
#macro CM_SPHERE_R		sphere[@ CM_SPHERE.R]
#macro CM_SPHERE_END	return sphere

function cm_sphere(x, y, z, radius, group = CM_GROUP_SOLID)
{
	CM_SPHERE_BEGIN;
	CM_SPHERE_TYPE = CM_OBJECTS.SPHERE;
	CM_SPHERE_GROUP = group;
	CM_SPHERE_X = x;
	CM_SPHERE_Y = y;
	CM_SPHERE_Z = z;
	CM_SPHERE_R = radius;
	CM_SPHERE_END;
}