/*
	This function displaces the collider out of the give shape.
*/

function cm_torus_displace(torus, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_TORUS_GROUP) == 0){return false;}
	
	var ref = __cmi_torus_get_capsule_ref(torus, collider);
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
	if (l == 0) return false;
	var _d = R / l;
	var dx = ref[0] - (cx + rx * _d);
	var dy = ref[1] - (cy + ry * _d);
	var dz = ref[2] - (cz + rz * _d);
	var _r = CM_TORUS_SMALLRADIUS + collider[CM.R];
	var d = point_distance_3d(dx, dy, dz, 0, 0, 0);
	if (d == 0 || d >= _r) return false;
	d = (_r - d) / d;
	return __cmi_collider_displace(collider, dx * d, dy * d, dz * d);
}