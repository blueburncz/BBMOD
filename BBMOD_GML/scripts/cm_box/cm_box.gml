enum CM_BOX
{
	TYPE, 
	GROUP,
	M, 
	I, 
	NUM
}

#macro CM_BOX_BEGIN var box = array_create(CM_BOX.NUM, CM_OBJECTS.BOX)
#macro CM_BOX_TYPE  box[@ CM_BOX.TYPE]
#macro CM_BOX_GROUP box[@ CM_BOX.GROUP]
#macro CM_BOX_M		box[@ CM_BOX.M]
#macro CM_BOX_I		box[@ CM_BOX.I]
#macro CM_BOX_END	return box

function cm_box(M, group = CM_GROUP_SOLID)
{
	CM_BOX_BEGIN;
	CM_BOX_GROUP = group;
	
	//Remove any potential shear from the matrix
	var m = array_create(16);
	array_copy(m, 0, M, 0, 16);
	cm_matrix_orthogonalize(m);
	CM_BOX_M = cm_matrix_scale(m, 
					point_distance_3d(0, 0, 0, M[0], M[1], M[2]),
					point_distance_3d(0, 0, 0, M[4], M[5], M[6]),
					point_distance_3d(0, 0, 0, M[8], M[9], M[10]));
	CM_BOX_I = matrix_inverse(m);	
	CM_BOX_END;
} 