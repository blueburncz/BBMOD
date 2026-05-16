// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_get_wireframe(object)
{
	var type = object[CM_TYPE];
	var vbuff = global.cm_vbuffers_wf[type];
	if (vbuff < 0)
	{
		switch type
		{
			case CM_OBJECTS.SPHERE:
				vbuff = cm_create_sphere_vbuff_wireframe(26, 18, 1, 1, c_white);
				break;
			case CM_OBJECTS.CAPSULE:
				vbuff = cm_create_capsule_vbuff_wireframe(26, 18, 1, 1, c_white);
				break;
			case CM_OBJECTS.CYLINDER:
				vbuff = cm_create_cylinder_vbuff_wireframe(26, 1, 1, c_white);
				break;
			case CM_OBJECTS.AAB:
				vbuff = cm_create_block_vbuff_wireframe(1, 1, c_white);
				break;
			case CM_OBJECTS.BOX:
				vbuff = cm_create_block_vbuff_wireframe(1, 1, c_white);
				break;
			case CM_OBJECTS.TORUS:
				vbuff = cm_create_torus_vbuff_wireframe(32, 18, 1, 1, c_white);
				break;
			case CM_OBJECTS.DISK:
				vbuff = cm_create_disk_vbuff_wireframe(32, 18, 1, 1, c_white);
				break;
		}
		global.cm_vbuffers_wf[type] = vbuff;
	}
	
	return vbuff;
}