// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_collider_cast_ray(collider, ray, mask = ray[CM_RAY.MASK])
{
	var X = collider[CM.X];
	var Y = collider[CM.Y];
	var Z = collider[CM.Z];
	var XUP = collider[CM.XUP];
	var YUP = collider[CM.YUP];
	var ZUP = collider[CM.ZUP];
	var R = collider[CM.R];
	var H = collider[CM.H];
	return cm_capsule_cast_ray(cm_capsule(X, Y, Z, X + XUP * H, Y + YUP * H, Z + ZUP * H, R), ray, mask);
}