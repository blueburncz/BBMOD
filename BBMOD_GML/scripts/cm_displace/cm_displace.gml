////////////////////////////////////////
// -- Displace capsule --
var default_function = function(object, collider, mask = collider[CM.MASK])
{
	var region = CM_GET_REGION(object, cm_collider_get_aabb(collider));
	//show_debug_message([cm_debug_string(object), array_length(region), region[1]]);
	return cm_list_displace(region, collider, mask);
}
global.__cmi_displace = array_create(CM_OBJECTS.NUM, default_function);
global.__cmi_displace[CM_OBJECTS.COLLIDERCAPSULE]	= function(object, collider, mask = collider[CM.MASK]){return cm_capsule_displace(cm_collider_get_capsule(object), collider, mask)};
global.__cmi_displace[CM_OBJECTS.DYNAMIC]			= cm_dynamic_displace;
global.__cmi_displace[CM_OBJECTS.LIST]				= cm_list_displace;
global.__cmi_displace[CM_OBJECTS.SPATIALHASH]		= default_function;
global.__cmi_displace[CM_OBJECTS.QUADTREE]			= default_function;
global.__cmi_displace[CM_OBJECTS.OCTREE]			= default_function;
global.__cmi_displace[CM_OBJECTS.FLSSTRIANGLE]		= cm_triangle_displace;
global.__cmi_displace[CM_OBJECTS.FLDSTRIANGLE]		= cm_triangle_displace;
global.__cmi_displace[CM_OBJECTS.SMSSTRIANGLE]		= cm_triangle_displace;
global.__cmi_displace[CM_OBJECTS.SMDSTRIANGLE]		= cm_triangle_displace;
global.__cmi_displace[CM_OBJECTS.SPHERE]			= cm_sphere_displace;
global.__cmi_displace[CM_OBJECTS.CAPSULE]			= cm_capsule_displace;
global.__cmi_displace[CM_OBJECTS.CYLINDER]			= cm_cylinder_displace;
global.__cmi_displace[CM_OBJECTS.AAB]				= cm_aab_displace;
global.__cmi_displace[CM_OBJECTS.BOX]				= cm_box_displace;
global.__cmi_displace[CM_OBJECTS.DISK]				= cm_disk_displace;
global.__cmi_displace[CM_OBJECTS.TORUS]				= cm_torus_displace;
#macro CM_DISPLACE global.__cmi_displace[object[0]]
function cm_displace(object, collider, mask = collider[CM.MASK])
{
	return CM_DISPLACE(object, collider, mask);
}