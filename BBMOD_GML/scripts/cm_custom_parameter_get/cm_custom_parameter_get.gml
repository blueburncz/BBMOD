// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_custom_parameter_get(object)
{
	var type = object[CM_TYPE];
	var ind = CM_CUSTOM_POS[type];
	if (ind <= 0 || array_length(object) <= ind)
	{
		return -1;
	}
	return object[ind];
}