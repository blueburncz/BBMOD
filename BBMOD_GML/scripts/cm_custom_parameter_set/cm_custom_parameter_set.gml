// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_custom_parameter_set(object, parameter)
{
	var type = object[CM_TYPE];
	var ind = CM_CUSTOM_POS[type];
	if (ind <= 0)
	{
		cm_debug_message("Error in function cm_custom_parameter_set: The object cannot contain a custom parameter!");
		return false;
	}
	object[@ ind] = parameter;
	return object;
}