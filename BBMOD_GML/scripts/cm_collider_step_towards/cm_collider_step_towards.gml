function cm_collider_step_towards(collider, object, targetX, targetY, targetZ, mask = collider[CM.MASK])
{
	var stepLength = collider[CM.R] * .5;
	var d = point_distance_3d(collider[CM.X], collider[CM.Y], collider[CM.Z], targetX, targetY, targetZ);
	var steps = ceil(d / stepLength);
	var col = false;
	while (steps)
	{
		var stepsize = min(stepLength, d / steps) / d;
		collider[@ CM.X] = lerp(collider[CM.X], targetX, stepsize);
		collider[@ CM.Y] = lerp(collider[CM.Y], targetY, stepsize);
		collider[@ CM.Z] = lerp(collider[CM.Z], targetZ, stepsize);
		col |= cm_displace(object, collider, mask);
		if (--steps)
		{
			d = point_distance_3d(collider[CM.X], collider[CM.Y], collider[CM.Z], targetX, targetY, targetZ);
		}
	}
	return col;
}