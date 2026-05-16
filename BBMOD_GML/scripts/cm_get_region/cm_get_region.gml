////////////////////////////////////////
// -- Get region --
var default_function = function(object, aabb)
{	
	static region = cm_list;
	if (cm_check_aabb(object, aabb))
	{
		region[CM_LIST.SIZE] = CM_LIST.NUM + 1;
		region[CM_LIST.NUM] = object;
	}
	else
	{
		region[CM_LIST.SIZE] = CM_LIST.NUM = 0;
	}
	return region;
}
global.__cmi_get_region = array_create(CM_OBJECTS.NUM, default_function); //General function, works for all objects that don't need custom functions
global.__cmi_get_region[CM_OBJECTS.LIST]		= cm_list_get_region;
global.__cmi_get_region[CM_OBJECTS.SPATIALHASH]	= cm_spatialhash_get_region;
global.__cmi_get_region[CM_OBJECTS.QUADTREE]	= cm_quadtree_get_region;
global.__cmi_get_region[CM_OBJECTS.OCTREE]		= cm_octree_get_region;
#macro CM_GET_REGION global.__cmi_get_region[object[CM_TYPE]]
function cm_get_region(object, aabb)
{
	return CM_GET_REGION(object, aabb);
}