////////////////////////////////////////
// -- Debug draw --
global.__cmi_debug_draw_wireframe = array_create(CM_OBJECTS.NUM);
global.__cmi_debug_draw_wireframe[CM_OBJECTS.COLLIDERCAPSULE]	= cm_collider_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.RAY]				= cm_ray_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.DYNAMIC]			= cm_dynamic_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.LIST]				= cm_list_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.SPATIALHASH]		= cm_spatialhash_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.QUADTREE]			= cm_quadtree_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.OCTREE]			= cm_octree_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.FLSSTRIANGLE]		= cm_triangle_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.FLDSTRIANGLE]		= cm_triangle_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.SMSSTRIANGLE]		= cm_triangle_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.SMDSTRIANGLE]		= cm_triangle_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.SPHERE]			= cm_sphere_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.CAPSULE]			= cm_capsule_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.CYLINDER]			= cm_cylinder_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.AAB]				= cm_aab_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.BOX]				= cm_box_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.DISK]				= cm_disk_debug_draw_wireframe;
global.__cmi_debug_draw_wireframe[CM_OBJECTS.TORUS]				= cm_torus_debug_draw_wireframe;
#macro CM_DEBUG_DRAW_WIREFRAME global.__cmi_debug_draw_wireframe[object[0]]
function cm_debug_draw_wireframe(object, tex = -1, color = -1, alpha = 1, mask = 0)
{
	return CM_DEBUG_DRAW_WIREFRAME(object, tex, color, alpha, mask);
}