////////////////////////////////////////
// -- Remove object from the given container --
var default_function = function(container, object)
{
	show_error("Error in function cm_remove_object: Cannot remove object from the given object. This function only works for container objects.", false);
}
global.__cmi_container_remove = array_create(CM_OBJECTS.NUM, default_function);
global.__cmi_container_remove[CM_OBJECTS.LIST]			= cm_list_remove;
global.__cmi_container_remove[CM_OBJECTS.SPATIALHASH]	= cm_spatialhash_remove;
global.__cmi_container_remove[CM_OBJECTS.QUADTREE]		= cm_quadtree_remove;
global.__cmi_container_remove[CM_OBJECTS.OCTREE]		= cm_octree_remove;
#macro CM_CONTAINER_REMOVE global.__cmi_container_remove[container[0]]
function cm_remove(container, object)
{
	return CM_CONTAINER_REMOVE(container, object);
}