enum CM_TRIANGLE
{
	TYPE, 
	GROUP,
	X1, 
	Y1, 
	Z1, 
	X2,
	Y2,
	Z2,
	X3,
	Y3,
	Z3,
	NX,
	NY,
	NZ,
	NUM
}

enum CM_ARGS_SMOOTHTRIANGLE
{
	N1 = CM_TRIANGLE.NUM,
	N2,
	N3,
	NUM
}

#macro CM_TRIANGLE_BEGIN	var triangle = array_create(CM_TRIANGLE.NUM)
#macro CM_TRIANGLE_TYPE		triangle[@ CM_TRIANGLE.TYPE]
#macro CM_TRIANGLE_GROUP	triangle[@ CM_TRIANGLE.GROUP]
#macro CM_TRIANGLE_X1		triangle[@ CM_TRIANGLE.X1]
#macro CM_TRIANGLE_Y1		triangle[@ CM_TRIANGLE.Y1]
#macro CM_TRIANGLE_Z1		triangle[@ CM_TRIANGLE.Z1]
#macro CM_TRIANGLE_X2		triangle[@ CM_TRIANGLE.X2]
#macro CM_TRIANGLE_Y2		triangle[@ CM_TRIANGLE.Y2]
#macro CM_TRIANGLE_Z2		triangle[@ CM_TRIANGLE.Z2]
#macro CM_TRIANGLE_X3		triangle[@ CM_TRIANGLE.X3]
#macro CM_TRIANGLE_Y3		triangle[@ CM_TRIANGLE.Y3]
#macro CM_TRIANGLE_Z3		triangle[@ CM_TRIANGLE.Z3]
#macro CM_TRIANGLE_NX		triangle[@ CM_TRIANGLE.NX]
#macro CM_TRIANGLE_NY		triangle[@ CM_TRIANGLE.NY]
#macro CM_TRIANGLE_NZ		triangle[@ CM_TRIANGLE.NZ]
#macro CM_TRIANGLE_N1		triangle[@ CM_ARGS_SMOOTHTRIANGLE.N1]
#macro CM_TRIANGLE_N2		triangle[@ CM_ARGS_SMOOTHTRIANGLE.N2]
#macro CM_TRIANGLE_N3		triangle[@ CM_ARGS_SMOOTHTRIANGLE.N3]
#macro CM_TRIANGLE_END		return triangle
									
function cm_triangle(singlesided, x1, y1, z1, x2, y2, z2, x3, y3, z3, n1 = undefined, n2 = undefined, n3 = undefined, group = CM_GROUP_SOLID)
{
	CM_TRIANGLE_BEGIN;
	CM_TRIANGLE_GROUP = group;
	CM_TRIANGLE_X1 = x1;
	CM_TRIANGLE_Y1 = y1;
	CM_TRIANGLE_Z1 = z1;
	CM_TRIANGLE_X2 = x2;
	CM_TRIANGLE_Y2 = y2;
	CM_TRIANGLE_Z2 = z2;
	CM_TRIANGLE_X3 = x3;
	CM_TRIANGLE_Y3 = y3;
	CM_TRIANGLE_Z3 = z3;
	var nx = (y2 - y1) * (z3 - z1) - (z2 - z1) * (y3 - y1);
	var ny = (z2 - z1) * (x3 - x1) - (x2 - x1) * (z3 - z1);
	var nz = (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1);
	var l = point_distance_3d(0, 0, 0, nx, ny, nz);
	if (l == 0)
	{
		cm_debug_message("Error in function cm_triangle: Trying to add triangle with zero area!");
		return false;
	}
	CM_TRIANGLE_NX = nx / l;
	CM_TRIANGLE_NY = ny / l;
	CM_TRIANGLE_NZ = nz / l;
	if (is_array(n1) && is_array(n2) && is_array(n3))
	{
		CM_TRIANGLE_TYPE = singlesided ? CM_OBJECTS.SMSSTRIANGLE : CM_OBJECTS.SMDSTRIANGLE;
		CM_TRIANGLE_N1 = n1;
		CM_TRIANGLE_N2 = n2;
		CM_TRIANGLE_N3 = n3;
	}
	else
	{
		CM_TRIANGLE_TYPE = singlesided ? CM_OBJECTS.FLSSTRIANGLE : CM_OBJECTS.FLDSTRIANGLE;
	}
	CM_TRIANGLE_END;
}