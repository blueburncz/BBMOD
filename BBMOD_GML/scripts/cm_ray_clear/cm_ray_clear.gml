function cm_ray_clear(ray, x1, y1, z1, x2, y2, z2, mask = -1)
{
	if (!is_array(ray)){ray = array_create(CM_RAY.NUM, CM_OBJECTS.RAY);}
	ray[@ CM_RAY.X1] = x1;
	ray[@ CM_RAY.Y1] = y1;
	ray[@ CM_RAY.Z1] = z1;
	ray[@ CM_RAY.X2] = x2;
	ray[@ CM_RAY.Y2] = y2;
	ray[@ CM_RAY.Z2] = z2;
	ray[@ CM_RAY.OBJECT] = 0;
	ray[@ CM_RAY.HIT] = false;
	ray[@ CM_RAY.X] = x2;
	ray[@ CM_RAY.Y] = y2;
	ray[@ CM_RAY.Z] = z2;
	ray[@ CM_RAY.MASK] = mask;
	ray[@ CM_RAY.T] = 1;
	return ray;
}