////////////////////////////////////////
// -- Debug draw --
global.__cmi_debug_string = array_create(CM_OBJECTS.NUM);
global.__cmi_debug_string[CM_OBJECTS.COLLIDERCAPSULE]	= cm_collider_debug_string;
global.__cmi_debug_string[CM_OBJECTS.DYNAMIC]			= cm_dynamic_debug_string;
global.__cmi_debug_string[CM_OBJECTS.LIST]				= cm_list_debug_string;
global.__cmi_debug_string[CM_OBJECTS.SPATIALHASH]		= cm_spatialhash_debug_string;
global.__cmi_debug_string[CM_OBJECTS.QUADTREE]			= cm_quadtree_debug_string;
global.__cmi_debug_string[CM_OBJECTS.OCTREE]			= cm_octree_debug_string;
global.__cmi_debug_string[CM_OBJECTS.FLSSTRIANGLE]		= cm_triangle_debug_string;
global.__cmi_debug_string[CM_OBJECTS.FLDSTRIANGLE]		= cm_triangle_debug_string;
global.__cmi_debug_string[CM_OBJECTS.SMSSTRIANGLE]		= cm_triangle_debug_string;
global.__cmi_debug_string[CM_OBJECTS.SMDSTRIANGLE]		= cm_triangle_debug_string;
global.__cmi_debug_string[CM_OBJECTS.SPHERE]			= cm_sphere_debug_string;
global.__cmi_debug_string[CM_OBJECTS.CAPSULE]			= cm_capsule_debug_string;
global.__cmi_debug_string[CM_OBJECTS.CYLINDER]			= cm_cylinder_debug_string;
global.__cmi_debug_string[CM_OBJECTS.AAB]				= cm_aab_debug_string;
global.__cmi_debug_string[CM_OBJECTS.BOX]				= cm_box_debug_string;
global.__cmi_debug_string[CM_OBJECTS.DISK]				= cm_disk_debug_string;
global.__cmi_debug_string[CM_OBJECTS.TORUS]				= cm_torus_debug_string;
#macro CM_DEBUG_STRING global.__cmi_debug_string[object[0]]
function cm_debug_string(object)
{
	return CM_DEBUG_STRING(object);
}