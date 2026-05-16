// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_ray_draw(ray, tex = -1, color = -1, radius = 5, mask = 0)
{
	cm_debug_draw(cm_capsule(ray[CM_RAY.X1], ray[CM_RAY.Y1], ray[CM_RAY.Z1], ray[CM_RAY.X], ray[CM_RAY.Y], ray[CM_RAY.Z], radius), tex, color);
}