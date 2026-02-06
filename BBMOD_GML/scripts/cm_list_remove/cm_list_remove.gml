function cm_list_remove(list, object)
{
	var num = list[CM_LIST.SIZE] - CM_LIST.NUM;
	var ind = array_get_index(list, object, CM_LIST.NUM, num);
	if (ind < CM_LIST.NUM || ind >= list[CM_LIST.SIZE]) return false;
	array_delete(list, ind, 1);
	list[@ CM_LIST.SIZE] -= 1;
	return true;
}