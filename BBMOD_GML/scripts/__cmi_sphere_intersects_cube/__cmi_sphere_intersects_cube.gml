function __cmi_sphere_intersects_cube(sphere, hsize, bX, bY, bZ) 
{
	var X = CM_SPHERE_X;
	var Y = CM_SPHERE_Y;
	var Z = CM_SPHERE_Z;
	var R = CM_SPHERE_R;
	var distSqr = R * R;
	var d = X - bX + hsize;
	if (d < 0)
	{
		distSqr -= d * d;
	}
	else
	{
		d = X - bX - hsize;
		if (d > 0)
		{
			distSqr -= d * d;
		}
	}
	d = Y - bY + hsize;
	if (d < 0)
	{
		distSqr -= d * d;
	}
	else
	{
		d = Y - bY - hsize;
		if (d > 0)
		{
			distSqr -= d * d;
		}
	}
	d = Z - bZ + hsize;
	if (d < 0)
	{
		distSqr -= d * d;
	}
	else
	{
		d = Z - bZ - hsize;
		if (d > 0)
		{
			distSqr -= d * d;
		}
	}
	return (distSqr > 0);
}