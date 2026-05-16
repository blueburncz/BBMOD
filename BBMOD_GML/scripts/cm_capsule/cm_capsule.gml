enum CM_CAPSULE
{
	TYPE, 
	GROUP,
	X1, 
	Y1, 
	Z1, 
	X2,
	Y2,
	Z2,
	R,
	NUM
}

#macro CM_CAPSULE_BEGIN	 var capsule = array_create(CM_CAPSULE.NUM, CM_OBJECTS.CAPSULE)
#macro CM_CAPSULE_TYPE   capsule[@ CM_CAPSULE.TYPE]
#macro CM_CAPSULE_GROUP  capsule[@ CM_CAPSULE.GROUP]
#macro CM_CAPSULE_R		 capsule[@ CM_CAPSULE.R]
#macro CM_CAPSULE_X1	 capsule[@ CM_CAPSULE.X1]
#macro CM_CAPSULE_Y1	 capsule[@ CM_CAPSULE.Y1]
#macro CM_CAPSULE_Z1	 capsule[@ CM_CAPSULE.Z1]
#macro CM_CAPSULE_X2	 capsule[@ CM_CAPSULE.X2]
#macro CM_CAPSULE_Y2	 capsule[@ CM_CAPSULE.Y2]
#macro CM_CAPSULE_Z2	 capsule[@ CM_CAPSULE.Z2]
#macro CM_CAPSULE_DX	 CM_CAPSULE_X2 - CM_CAPSULE_X1
#macro CM_CAPSULE_DY	 CM_CAPSULE_Y2 - CM_CAPSULE_Y1
#macro CM_CAPSULE_DZ	 CM_CAPSULE_Z2 - CM_CAPSULE_Z1
#macro CM_CAPSULE_END	 return capsule

function cm_capsule(x1, y1, z1, x2, y2, z2, radius, group = CM_GROUP_SOLID)
{
	CM_CAPSULE_BEGIN;
	CM_CAPSULE_GROUP = group;
	CM_CAPSULE_X1 = x1;
	CM_CAPSULE_Y1 = y1;
	CM_CAPSULE_Z1 = z1;
	CM_CAPSULE_X2 = x2;
	CM_CAPSULE_Y2 = y2;
	CM_CAPSULE_Z2 = z2;
	CM_CAPSULE_R = radius;
	CM_CAPSULE_END;
}