enum CM
{
	TYPE,
	X, 
	Y, 
	Z, 
	NX,
	NY,
	NZ,
	COLLISION,
	XUP,
	YUP,
	ZUP,
	R,
	H,
	MASK,
	SLOPEANGLE,
	PRECISION,
	MAXDP,
	SLOPE,
	REGION,
	GROUND,
	COLLISIONS,
	TRANSFORMATIONS,
	NUM
}

function cm_collider(X, Y, Z, xup, yup, zup, radius, height, slopeAngle = 40, precision = 0, mask = 0)
{
	var collider = array_create(CM.NUM);
	collider[@ CM.TYPE] = CM_OBJECTS.COLLIDERCAPSULE;
	collider[@ CM.X] = X;
	collider[@ CM.Y] = Y;
	collider[@ CM.Z] = Z;
	collider[@ CM.XUP] = xup;
	collider[@ CM.YUP] = yup;
	collider[@ CM.ZUP] = zup;
	collider[@ CM.R] = radius;
	collider[@ CM.H] = height;
	collider[@ CM.MASK] = mask;
	collider[@ CM.PRECISION] = precision;
	collider[@ CM.SLOPEANGLE] = slopeAngle;
	return __cmi_collider_reset(collider);
}

function __cmi_collider_reset(collider)
{
	collider[@ CM.MAXDP] = -1;
	collider[@ CM.REGION] = cm_list();
	collider[@ CM.GROUND] = false;
	collider[@ CM.COLLISIONS] = [];
	collider[@ CM.COLLISION] = false;
	collider[@ CM.TRANSFORMATIONS] = [];
	collider[@ CM.SLOPE] = ((collider[CM.SLOPEANGLE] <= 0) ? 1 : dcos(collider[CM.SLOPEANGLE]));
	return collider;
}

function __cmi_collider_displace(collider, dx, dy, dz)
{
	var d  = point_distance_3d(dx, dy, dz, 0, 0, 0);
	if (d == 0)
	{
		return false;
	}
	var dp = dot_product_3d(dx, dy, dz, collider[CM.XUP], collider[CM.YUP], collider[CM.ZUP]) / d;
	if (dp > collider[CM.MAXDP])
	{
		//Store the normal vector that is the most parallel to the given up vector
		collider[@ CM.NX] = dx / d;
		collider[@ CM.NY] = dy / d;
		collider[@ CM.NZ] = dz / d;
		collider[@ CM.MAXDP] = dp;
	}
	if (dp >= collider[CM.SLOPE])
	{ 
		//Prevent sliding by displacing along the up vector instead of the normal vector
		d /= dp;
		collider[@ CM.X] += collider[CM.XUP] * d;
		collider[@ CM.Y] += collider[CM.YUP] * d;
		collider[@ CM.Z] += collider[CM.ZUP] * d;
		collider[@ CM.GROUND] = true;
		collider[@ CM.SLOPE] = 1;
	}
	else
	{
		collider[@ CM.X] += dx;
		collider[@ CM.Y] += dy;
		collider[@ CM.Z] += dz;
	}
	collider[@ CM.COLLISION] = true;
	return true;
}