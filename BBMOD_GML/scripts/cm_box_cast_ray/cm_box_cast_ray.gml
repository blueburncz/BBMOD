function cm_box_cast_ray(box, ray, mask = ray[CM_RAY.MASK])
{
	if (mask != 0 && (mask & CM_BOX_GROUP) == 0){return ray;}
	
	var M = CM_BOX_M;
	var I = CM_BOX_I;
	var T = ray[CM_RAY.T];
	
	//Algorithm created by TheSnidr
	var o = matrix_transform_vertex(I, ray[CM_RAY.X1], ray[CM_RAY.Y1], ray[CM_RAY.Z1]);
	var e = matrix_transform_vertex(I, ray[CM_RAY.X2], ray[CM_RAY.Y2], ray[CM_RAY.Z2]);
	var x1 = o[0], y1 = o[1], z1 = o[2];
	var x2 = e[0], y2 = e[1], z2 = e[2];
	
	var nx = 0, ny = 0, nz = 1;
	if (x2 != x1 && abs(x1) > 1)
	{
		var s = sign(x1 - x2);
		var t = (s - x1) / (x2 - x1);
		if (t >= 0 && t <= T)
		{
			var itsY = lerp(y1, y2, t);
			var itsZ = lerp(z1, z2, t);
			if (abs(itsY) <= 1 && abs(itsZ) <= 1)
			{
				var n = s / point_distance_3d(0, 0, 0, M[0], M[1], M[2]);
				var p = matrix_transform_vertex(M, s, itsY, itsZ);
				ray[@ CM_RAY.T] = t;
				ray[@ CM_RAY.HIT] = true;
				ray[@ CM_RAY.X] = p[0];
				ray[@ CM_RAY.Y] = p[1];
				ray[@ CM_RAY.Z] = p[2];
				ray[@ CM_RAY.NX] = M[0] * n;
				ray[@ CM_RAY.NY] = M[1] * n;
				ray[@ CM_RAY.NZ] = M[2] * n;
				ray[@ CM_RAY.OBJECT] = box;
				return ray;
			}
		}
	}
	if (y2 != y1 && abs(y1) > 1)
	{
		var s = sign(y1 - y2);
		var t = (s - y1) / (y2 - y1);
		if (t >= 0 && t <= T)
		{
			var itsX = lerp(x1, x2, t);
			var itsZ = lerp(z1, z2, t);
			if (abs(itsX) <= 1 && abs(itsZ) <= 1)
			{
				var n = s / point_distance_3d(0, 0, 0, M[4], M[5], M[6]);
				var p = matrix_transform_vertex(M, itsX, s, itsZ);
				ray[@ CM_RAY.T] = t;
				ray[@ CM_RAY.HIT] = true;
				ray[@ CM_RAY.X] = p[0];
				ray[@ CM_RAY.Y] = p[1];
				ray[@ CM_RAY.Z] = p[2];
				ray[@ CM_RAY.NX] = M[4] * n;
				ray[@ CM_RAY.NY] = M[5] * n;
				ray[@ CM_RAY.NZ] = M[6] * n;
				ray[@ CM_RAY.OBJECT] = box;
				return ray;
			}
		}
	}
	if (z2 != z1 && abs(z1) > 1)
	{
		var s = sign(z1 - z2);
		var t = (s - z1) / (z2 - z1);
		if (t >= 0 && t <= T)
		{
			var itsX = lerp(x1, x2, t);
			var itsY = lerp(y1, y2, t);
			if (abs(itsX) <= 1 && abs(itsY) <= 1)
			{
				var n = s / point_distance_3d(0, 0, 0, M[8], M[9], M[10]);
				var p = matrix_transform_vertex(M, itsX, itsY, s);
				ray[@ CM_RAY.T] = t;
				ray[@ CM_RAY.HIT] = true;
				ray[@ CM_RAY.X] = p[0];
				ray[@ CM_RAY.Y] = p[1];
				ray[@ CM_RAY.Z] = p[2];
				ray[@ CM_RAY.NX] = M[8] * n;
				ray[@ CM_RAY.NY] = M[9] * n;
				ray[@ CM_RAY.NZ] = M[10] * n;
				ray[@ CM_RAY.OBJECT] = box;
				return ray;
			}
		}
	}
	return ray;
}