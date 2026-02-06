////////////////////////////////////////
// -- check capsule --
var default_function = function(object, collider, mask = collider[CM.MASK])
{
	return cm_list_check(CM_GET_REGION(object, cm_collider_get_aabb(collider)), collider, mask);
}
global.__cmi_check = array_create(CM_OBJECTS.NUM, default_function);
global.__cmi_check[CM_OBJECTS.COLLIDERCAPSULE]	= function(object, collider, mask = collider[CM.MASK]){return cm_capsule_check(cm_collider_get_capsule(object), collider, mask)};
global.__cmi_check[CM_OBJECTS.DYNAMIC]			= cm_dynamic_check;
global.__cmi_check[CM_OBJECTS.LIST]				= cm_list_check;
global.__cmi_check[CM_OBJECTS.SPATIALHASH]		= default_function;
global.__cmi_check[CM_OBJECTS.QUADTREE]			= default_function;
global.__cmi_check[CM_OBJECTS.OCTREE]			= default_function;
global.__cmi_check[CM_OBJECTS.FLSSTRIANGLE]		= cm_triangle_check;
global.__cmi_check[CM_OBJECTS.FLDSTRIANGLE]		= cm_triangle_check;
global.__cmi_check[CM_OBJECTS.SMSSTRIANGLE]		= cm_triangle_check;
global.__cmi_check[CM_OBJECTS.SMDSTRIANGLE]		= cm_triangle_check;
global.__cmi_check[CM_OBJECTS.SPHERE]			= cm_sphere_check;
global.__cmi_check[CM_OBJECTS.CAPSULE]			= cm_capsule_check;
global.__cmi_check[CM_OBJECTS.CYLINDER]			= cm_cylinder_check;
global.__cmi_check[CM_OBJECTS.AAB]				= cm_aab_check;
global.__cmi_check[CM_OBJECTS.BOX]				= cm_box_check;
global.__cmi_check[CM_OBJECTS.DISK]				= cm_disk_check;
global.__cmi_check[CM_OBJECTS.TORUS]			= cm_torus_check;
#macro CM_CHECK global.__cmi_check[object[0]]
function cm_check(object, collider, mask = collider[CM.MASK])
{
	return CM_CHECK(object, collider, mask);
}