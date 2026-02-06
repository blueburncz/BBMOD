////////////////////////////////////////
// -- Debug draw --
global.__cmi_debug_draw = array_create(CM_OBJECTS.NUM);
global.__cmi_debug_draw[CM_OBJECTS.COLLIDERCAPSULE]	= cm_collider_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.RAY]				= cm_ray_draw;
global.__cmi_debug_draw[CM_OBJECTS.DYNAMIC]			= cm_dynamic_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.LIST]			= cm_list_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.SPATIALHASH]		= cm_spatialhash_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.QUADTREE]		= cm_quadtree_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.OCTREE]			= cm_octree_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.FLSSTRIANGLE]	= cm_triangle_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.FLDSTRIANGLE]	= cm_triangle_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.SMSSTRIANGLE]	= cm_triangle_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.SMDSTRIANGLE]	= cm_triangle_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.SPHERE]			= cm_sphere_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.CAPSULE]			= cm_capsule_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.CYLINDER]		= cm_cylinder_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.AAB]				= cm_aab_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.BOX]				= cm_box_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.DISK]			= cm_disk_debug_draw;
global.__cmi_debug_draw[CM_OBJECTS.TORUS]			= cm_torus_debug_draw;
#macro CM_DEBUG_DRAW global.__cmi_debug_draw[object[0]]
function cm_debug_draw(object, tex = -1, color = -1, alpha = 1, mask = 0)
{
	return CM_DEBUG_DRAW(object, tex, color, alpha, mask);
}