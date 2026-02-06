////////////////////////////////////////
// -- Get axis-aligned bounding box --
global.__cmi_get_aabb = array_create(CM_OBJECTS.NUM);
global.__cmi_get_aabb[CM_OBJECTS.COLLIDERCAPSULE]	= cm_collider_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.DYNAMIC]			= cm_dynamic_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.LIST]				= cm_list_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.SPATIALHASH]		= cm_spatialhash_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.QUADTREE]			= cm_quadtree_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.OCTREE]			= cm_octree_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.FLSSTRIANGLE]		= cm_triangle_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.FLDSTRIANGLE]		= cm_triangle_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.SMSSTRIANGLE]		= cm_triangle_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.SMDSTRIANGLE]		= cm_triangle_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.SPHERE]			= cm_sphere_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.CAPSULE]			= cm_capsule_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.CYLINDER]			= cm_cylinder_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.AAB]				= cm_aab_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.BOX]				= cm_box_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.DISK]				= cm_disk_get_aabb;
global.__cmi_get_aabb[CM_OBJECTS.TORUS]				= cm_torus_get_aabb;
#macro CM_GET_AABB global.__cmi_get_aabb[object[0]]
function cm_get_aabb(object)
{
	return CM_GET_AABB(object);
}