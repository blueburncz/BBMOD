enum CM_TORUS
{
	TYPE, 
	GROUP,
	X, 
	Y, 
	Z,
	NX,
	NY,
	NZ,
	BIGRADIUS,
	SMALLRADIUS,
	NUM
}

#macro CM_TORUS_BEGIN		var torus = array_create(CM_TORUS.NUM, CM_OBJECTS.TORUS)
#macro CM_TORUS_TYPE		torus[@ CM_TORUS.TYPE]
#macro CM_TORUS_GROUP		torus[@ CM_TORUS.GROUP]
#macro CM_TORUS_X			torus[@ CM_TORUS.X]
#macro CM_TORUS_Y			torus[@ CM_TORUS.Y]
#macro CM_TORUS_Z			torus[@ CM_TORUS.Z]
#macro CM_TORUS_NX			torus[@ CM_TORUS.NX]
#macro CM_TORUS_NY			torus[@ CM_TORUS.NY]
#macro CM_TORUS_NZ			torus[@ CM_TORUS.NZ]
#macro CM_TORUS_BIGRADIUS	torus[@ CM_TORUS.BIGRADIUS]
#macro CM_TORUS_SMALLRADIUS	torus[@ CM_TORUS.SMALLRADIUS]
#macro CM_TORUS_END			return torus

function cm_torus(x, y, z, nx, ny, nz, bigradius, smallradius, group = CM_GROUP_SOLID)
{
	var n = point_distance_3d(0, 0, 0, nx, ny, nz);
	CM_TORUS_BEGIN;
	CM_TORUS_GROUP = group;
	CM_TORUS_X = x;
	CM_TORUS_Y = y;
	CM_TORUS_Z = z;
	CM_TORUS_NX = nx / n;
	CM_TORUS_NY = ny / n;
	CM_TORUS_NZ = nz / n;
	CM_TORUS_BIGRADIUS = bigradius;
	CM_TORUS_SMALLRADIUS = smallradius;
	CM_TORUS_END;
} 





