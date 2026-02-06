function cm_triangle_debug_string(triangle)
{
	var type = triangle[CM_TYPE];
	if (type == CM_OBJECTS.FLSSTRIANGLE)
	{
		return string("[Flat SS triangle: Group: {12}, v1: [{0}, {1}, {2}] v2: [{3}, {4}, {5}] v3: [{6}, {7}, {8}] n: [{9}, {10}, {11}]]", 
					CM_TRIANGLE_X1, CM_TRIANGLE_Y1, CM_TRIANGLE_Z1,
					CM_TRIANGLE_X2, CM_TRIANGLE_Y2, CM_TRIANGLE_Z2,
					CM_TRIANGLE_X3, CM_TRIANGLE_Y3, CM_TRIANGLE_Z3,
					CM_TRIANGLE_NX, CM_TRIANGLE_NY, CM_TRIANGLE_NZ,
					CM_TRIANGLE_GROUP);
	}
	if (type == CM_OBJECTS.FLDSTRIANGLE)
	{
		return string("[Flat DS triangle: Group: {12}, v1: [{0}, {1}, {2}] v2: [{3}, {4}, {5}] v3: [{6}, {7}, {8}] n: [{9}, {10}, {11}]]", 
					CM_TRIANGLE_X1, CM_TRIANGLE_Y1, CM_TRIANGLE_Z1,
					CM_TRIANGLE_X2, CM_TRIANGLE_Y2, CM_TRIANGLE_Z2,
					CM_TRIANGLE_X3, CM_TRIANGLE_Y3, CM_TRIANGLE_Z3,
					CM_TRIANGLE_NX, CM_TRIANGLE_NY, CM_TRIANGLE_NZ,
					CM_TRIANGLE_GROUP);
	}
	if (type == CM_OBJECTS.SMSSTRIANGLE)
	{
		return string("[Smooth SS triangle: Group: {15}, v1: [{0}, {1}, {2}] v2: [{3}, {4}, {5}] v3: [{6}, {7}, {8}] n: [{9}, {10}, {11}, n1: {12}, n2: {13}, n3: {14}]]", 
					CM_TRIANGLE_X1, CM_TRIANGLE_Y1, CM_TRIANGLE_Z1,
					CM_TRIANGLE_X2, CM_TRIANGLE_Y2, CM_TRIANGLE_Z2,
					CM_TRIANGLE_X3, CM_TRIANGLE_Y3, CM_TRIANGLE_Z3,
					CM_TRIANGLE_NX, CM_TRIANGLE_NY, CM_TRIANGLE_NZ,
					CM_TRIANGLE_N1, CM_TRIANGLE_N2, CM_TRIANGLE_N3,
					CM_TRIANGLE_GROUP);
	}
	if (type == CM_OBJECTS.SMDSTRIANGLE)
	{
		return string("[Smooth DS triangle: Group: {15}, v1: [{0}, {1}, {2}] v2: [{3}, {4}, {5}] v3: [{6}, {7}, {8}] n: [{9}, {10}, {11}, n1: {12}, n2: {13}, n3: {14}]]", 
					CM_TRIANGLE_X1, CM_TRIANGLE_Y1, CM_TRIANGLE_Z1,
					CM_TRIANGLE_X2, CM_TRIANGLE_Y2, CM_TRIANGLE_Z2,
					CM_TRIANGLE_X3, CM_TRIANGLE_Y3, CM_TRIANGLE_Z3,
					CM_TRIANGLE_NX, CM_TRIANGLE_NY, CM_TRIANGLE_NZ,
					CM_TRIANGLE_N1, CM_TRIANGLE_N2, CM_TRIANGLE_N3,
					CM_TRIANGLE_GROUP);
	}
}