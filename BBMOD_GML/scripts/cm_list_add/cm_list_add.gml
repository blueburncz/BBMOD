function cm_list_add(list, object)
{
	//If the object is an object list (which is what's created when loading a mesh), add each element individually
	if (object[CM_TYPE] == CM_OBJECTS.LIST)
	{
		var num = object[CM_LIST.SIZE] - CM_LIST.NUM;
		array_copy(list, list[CM_LIST.SIZE], object, CM_LIST.NUM, num);
		list[@ CM_LIST.SIZE] += num;
		return object;
	}
	
	list[@ list[CM_LIST.SIZE]] = object;
	list[@ CM_LIST.SIZE] += 1;
	return object;
}