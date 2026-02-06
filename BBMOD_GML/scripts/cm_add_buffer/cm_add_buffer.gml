function cm_add_buffer(container, buffer, bytes_per_vertex = 36, matrix = undefined, singlesided = true, smoothnormals = false, group = CM_GROUP_SOLID)
{
	/*
		Loads triangles from a buffer containing a triangle mesh into ColMesh.
		The first two attributes of the vertex format must be position (3 x buffer_f32) and normal (3 x buffer_f32)
	*/
	var vertnum = buffer_get_size(buffer) / bytes_per_vertex;
	var v = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
	var n = smoothnormals ? [[0, 0, 0], [0, 0, 0], [0, 0, 0]] : [0, 0, 0];
	var normalmatrix = undefined;
	if (is_array(matrix)){
		normalmatrix = cm_matrix_transpose(cm_matrix_invert_orientation(matrix));
	}
	
	cm_debug_message($"Script cm_add_buffer: Attempting to load buffer containing {vertnum div 3} triangles");
	
	//Loop through all triangles of this buffer
	for (var i = 0; i < vertnum; i += 3){
		//Loop through the vertices of this triangle
		for (var j = 0; j < 3; ++j){
			buffer_seek(buffer, buffer_seek_start, (i + j) * bytes_per_vertex);
			
			//Load vertex position
			v[j][0] = buffer_read(buffer, buffer_f32);
			v[j][1] = buffer_read(buffer, buffer_f32);
			v[j][2] = buffer_read(buffer, buffer_f32);
			if (is_array(matrix)) v[j] = matrix_transform_vertex(matrix, v[j][0], v[j][1], v[j][2]);
			
			//Load normal
			if (smoothnormals){
				n[j][0] = buffer_read(buffer, buffer_f32);
				n[j][1] = buffer_read(buffer, buffer_f32);
				n[j][2] = buffer_read(buffer, buffer_f32);
				
				if (is_array(normalmatrix)){
					var _n = matrix_transform_vertex(normalmatrix, n[j][0], n[j][1], n[j][2], 0);
					var l = point_distance_3d(0, 0, 0, _n[0], _n[1], _n[2]);
					n[j][0] = _n[0] / l;
					n[j][1] = _n[1] / l;
					n[j][2] = _n[2] / l;
				}
			}
		}
		cm_add(container, cm_triangle(singlesided, v[0][0], v[0][1], v[0][2], v[1][0], v[1][1], v[1][2], v[2][0], v[2][1], v[2][2], n[0], n[1], n[2], group));
	}
	cm_debug_message($"Script cm_add_buffer: Successfully loaded buffer with {vertnum div 3} triangles");
	return container;
}