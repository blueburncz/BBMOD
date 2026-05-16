function __cmi_torus_get_priority(torus, collider, mask = collider[CM.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Returns -1 if the shape is too far away
		Returns the square of the distance between the shape and the given point
	*/
	if (mask != 0 && (mask & CM_TORUS_GROUP) == 0){return -1;}
	
	//Read collider array
	var ref = __cmi_torus_get_capsule_ref(torus, collider);
	var maxR = collider[CM.R] * CM_FIRST_PASS_RADIUS;
	
	var cx = CM_TORUS_X;
	var cy = CM_TORUS_Y;
	var cz = CM_TORUS_Z;
	var nx = CM_TORUS_NX;
	var ny = CM_TORUS_NY;
	var nz = CM_TORUS_NZ;
	var r  = CM_TORUS_SMALLRADIUS;
	var R  = CM_TORUS_BIGRADIUS;
	
	var rx = ref[0] - cx;
	var ry = ref[1] - cy;
	var rz = ref[2] - cz;
	var dp = dot_product_3d(rx, ry, rz, nx, ny, nz);
	rx -= nx * dp;
	ry -= ny * dp;
	rz -= nz * dp;
	var l = point_distance_3d(0, 0, 0, rx, ry, rz);
	if (l == 0) return -1;
	var _d = R / l;
	var dx = ref[0] - (cx + rx * _d);
	var dy = ref[1] - (cy + ry * _d);
	var dz = ref[2] - (cz + rz * _d);
	var d = max(point_distance_3d(dx, dy, dz, 0, 0, 0) - CM_TORUS_SMALLRADIUS, 0);
	if (d > maxR){return -1;}
	return d * d;
}