// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_collider_debug_draw_wireframe(collider, tex = -1, color = c_purple, alpha = 1, mask = 0)
{
	return cm_capsule_debug_draw_wireframe(cm_collider_get_capsule(collider), tex, color, alpha);
}