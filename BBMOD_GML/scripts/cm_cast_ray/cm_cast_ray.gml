/*
	This function lets you cast a ray against the given object.
	The ray must be created with cm_ray(x1, y1, z1, x2, y2, z2, mask)
*/
global.__cmi_cast_ray = array_create(CM_OBJECTS.NUM);
global.__cmi_cast_ray[CM_OBJECTS.COLLIDERCAPSULE]	= cm_collider_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.DYNAMIC]			= cm_dynamic_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.LIST]				= cm_list_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.SPATIALHASH]		= cm_spatialhash_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.QUADTREE]			= cm_quadtree_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.OCTREE]			= cm_octree_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.FLSSTRIANGLE]		= cm_triangle_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.FLDSTRIANGLE]		= cm_triangle_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.SMSSTRIANGLE]		= cm_triangle_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.SMDSTRIANGLE]		= cm_triangle_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.SPHERE]			= cm_sphere_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.CAPSULE]			= cm_capsule_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.CYLINDER]			= cm_cylinder_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.AAB]				= cm_aab_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.BOX]				= cm_box_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.DISK]				= cm_disk_cast_ray;
global.__cmi_cast_ray[CM_OBJECTS.TORUS]				= cm_torus_cast_ray;
#macro CM_CAST_RAY global.__cmi_cast_ray[object[CM_TYPE]]
function cm_cast_ray(object, ray, mask = ray[CM_RAY.MASK])
{
	return CM_CAST_RAY(object, ray, mask);
}