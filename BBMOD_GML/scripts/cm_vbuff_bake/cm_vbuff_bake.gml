/*
	This function lets you bake a shape into a vertex buffer. Useful for debugging.
*/

global.__cmi_debug_bake = array_create(CM_OBJECTS.NUM);
global.__cmi_debug_bake[CM_OBJECTS.COLLIDERCAPSULE]	= function(collider, vbuff, matrix = matrix_build_identity(), mask = 0, hrep = 1, vrep = 1, color = -1, alpha = 1)
														{cm_capsule_debug_bake(cm_collider_get_capsule(collider), vbuff, matrix, mask, hrep, vrep, color, alpha);};
global.__cmi_debug_bake[CM_OBJECTS.DYNAMIC]			= cm_dynamic_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.LIST]			= cm_list_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.SPATIALHASH]		= cm_spatialhash_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.QUADTREE]		= cm_quadtree_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.OCTREE]			= cm_octree_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.FLSSTRIANGLE]	= cm_triangle_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.FLDSTRIANGLE]	= cm_triangle_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.SMSSTRIANGLE]	= cm_triangle_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.SMDSTRIANGLE]	= cm_triangle_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.SPHERE]			= cm_sphere_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.CAPSULE]			= cm_capsule_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.CYLINDER]		= cm_cylinder_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.AAB]				= cm_aab_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.BOX]				= cm_box_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.DISK]			= cm_disk_debug_bake;
global.__cmi_debug_bake[CM_OBJECTS.TORUS]			= cm_torus_debug_bake;
#macro CM_VBUFF_BAKE global.__cmi_debug_bake[object[0]]

function cm_vbuff_bake(object, vbuff, matrix = matrix_build_identity(), mask = 0, hrep = 1, vrep = 1, color = -1, alpha = 1)
{
	return CM_VBUFF_BAKE(object, vbuff, matrix, mask, hrep, vrep, color, alpha);
}