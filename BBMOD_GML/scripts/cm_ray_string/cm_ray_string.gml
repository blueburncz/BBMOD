// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_ray_string(ray)
{
	return $"Ray: Start: [{ray[CM_RAY.X1]},{ray[CM_RAY.Y1]},{ray[CM_RAY.Z1]}], End: [{ray[CM_RAY.X2]},{ray[CM_RAY.Y2]},{ray[CM_RAY.Z2]}], Intersects: {ray[CM_RAY.OBJECT]}";
}