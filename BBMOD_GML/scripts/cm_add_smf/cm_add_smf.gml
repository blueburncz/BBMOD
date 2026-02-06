// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function cm_add_smf(container, smfmodel, matrix = undefined, singlesided = true, smoothnormals = false, group = CM_GROUP_SOLID)
{
	var n = [undefined, undefined, undefined];
	var v, normalmatrix;
	var models = smfmodel.mBuff;
	var modelNum = array_length(models);
	
	if (is_array(matrix)) normalmatrix = cm_matrix_transpose(cm_matrix_invert_orientation(matrix));
	
	//Loop through the loaded information and generate a model
	for (var m = 0; m < modelNum; ++m)
	{
		var mbuff = models[m];
		var mbuff_bytes_per_vertex = 44;//mBuffBytesPerVert; //This is a macro in the SMF system
		var buffersize = buffer_get_size(mbuff);
		buffer_seek(mbuff, buffer_seek_start, 0);
		repeat (buffersize / mbuff_bytes_per_vertex) div 3
		{
			for (var i = 0; i < 3; ++i)
			{
				v[i][0] = buffer_read(mbuff, buffer_f32);
				v[i][1] = buffer_read(mbuff, buffer_f32);
				v[i][2] = buffer_read(mbuff, buffer_f32);
				if (is_array(matrix)) v[i] = matrix_transform_vertex(matrix, v[i][0], v[i][1], v[i][2]);
				if (smoothnormals)
				{
					n[i][0] = buffer_read(mbuff, buffer_f32);
					n[i][1] = buffer_read(mbuff, buffer_f32);
					n[i][2] = buffer_read(mbuff, buffer_f32);
					if (is_array(matrix)) n[i] = matrix_transform_vertex(normalmatrix, n[i][0], n[i][1], n[i][2], 0);
				}
				buffer_seek(mbuff, buffer_seek_relative, mbuff_bytes_per_vertex);
			}
			
			cm_add(container, cm_triangle(singlesided, v[0][0], v[0][1], v[0][2], v[1][0], v[1][1], v[1][2], v[2][0], v[2][1], v[2][2], n[0], n[1], n[2], group));
		}
	}
	cm_debug_message("Script cm_add_smf: Successfully added SMF model to colmesh");
	return container;
}