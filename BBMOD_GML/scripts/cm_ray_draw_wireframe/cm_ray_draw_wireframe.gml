// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_ray_draw_wireframe(ray, tex = -1, color = -1, alpha = 1, mask = -1, radius = 5)
{
	cm_debug_draw_wireframe(cm_capsule(ray[CM_RAY.X1], ray[CM_RAY.Y1], ray[CM_RAY.Z1], ray[CM_RAY.X], ray[CM_RAY.Y], ray[CM_RAY.Z], radius), tex, color, alpha);
}