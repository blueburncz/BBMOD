////////////////////////////////////////
// -- Get closest point --
global.__cmi_get_closest_point = array_create(CM_OBJECTS.NUM);
global.__cmi_get_closest_point[CM_OBJECTS.COLLIDERCAPSULE]	= function(object, x, y, z){return cm_capsule_get_closest_point(cm_collider_get_capsule(object), x, y, z)};
global.__cmi_get_closest_point[CM_OBJECTS.LIST]				= cm_list_get_closest_point;
global.__cmi_get_closest_point[CM_OBJECTS.FLSSTRIANGLE]		= cm_triangle_get_closest_point;
global.__cmi_get_closest_point[CM_OBJECTS.FLDSTRIANGLE]		= cm_triangle_get_closest_point;
global.__cmi_get_closest_point[CM_OBJECTS.SMSSTRIANGLE]		= cm_triangle_get_closest_point;
global.__cmi_get_closest_point[CM_OBJECTS.SMDSTRIANGLE]		= cm_triangle_get_closest_point;
global.__cmi_get_closest_point[CM_OBJECTS.SPHERE]			= cm_sphere_get_closest_point;
global.__cmi_get_closest_point[CM_OBJECTS.CAPSULE]			= cm_capsule_get_closest_point;
global.__cmi_get_closest_point[CM_OBJECTS.CYLINDER]			= cm_cylinder_get_closest_point;
global.__cmi_get_closest_point[CM_OBJECTS.AAB]				= cm_aab_get_closest_point;
global.__cmi_get_closest_point[CM_OBJECTS.BOX]				= cm_box_get_closest_point;
global.__cmi_get_closest_point[CM_OBJECTS.DISK]				= cm_disk_get_closest_point;
global.__cmi_get_closest_point[CM_OBJECTS.TORUS]			= cm_torus_get_closest_point;
#macro CM_GET_CLOSEST_POINT global.__cmi_get_closest_point[object[0]]
function cm_get_closest_point(object, x, y, z)
{
	return CM_GET_CLOSEST_POINT(object, x, y, z);
}