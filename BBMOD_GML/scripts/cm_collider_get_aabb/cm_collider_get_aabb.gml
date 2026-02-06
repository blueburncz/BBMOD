// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_collider_get_aabb(collider)
{
	var AABB = array_create(6);
	var radius = collider[CM.R];
	var height = collider[CM.H];
	var X = collider[CM.X];
	var Y = collider[CM.Y];
	var Z = collider[CM.Z];
	var xup = collider[CM.XUP] * height;
	var yup = collider[CM.YUP] * height;
	var zup = collider[CM.ZUP] * height;
	AABB[@ 0] = X + min(xup, 0) - radius;
	AABB[@ 1] = Y + min(yup, 0) - radius;
	AABB[@ 2] = Z + min(zup, 0) - radius;
	AABB[@ 3] = X + max(xup, 0) + radius;
	AABB[@ 4] = Y + max(yup, 0) + radius;
	AABB[@ 5] = Z + max(zup, 0) + radius;
	return AABB;
}