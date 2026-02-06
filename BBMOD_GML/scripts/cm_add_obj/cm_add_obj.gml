// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function cm_load_obj(filename, matrix = undefined, singlesided = true, smoothnormals = false, group = CM_GROUP_SOLID)
{
	return cm_add_obj(cm_list(), filename, matrix, singlesided, smoothnormals, group);
}

function cm_add_obj(container, filename, matrix = undefined, singlesided = true, smoothnormals = false, group = CM_GROUP_SOLID)
{
	var buffer = buffer_load(filename);
	if (buffer == -1)
	{
		cm_debug_message("Function cm_add_obj: Failed to load model " + string(filename)); 
		return -1;
	}
	cm_debug_message("Function cm_add_obj: Loading obj file " + string(filename));

	var contents = buffer_read(buffer, buffer_text);
	var lines = string_split(contents, "\n");
	var num = array_length(lines);

	//Create the necessary arrays
	var face_verts = array_create(5);
	var V = array_create(num);
	var N = array_create(num);
	var T = array_create(num);
	var F = array_create(num);
	var V_num = 0;
	var N_num = 0;
	var T_num = 0;
	var F_num = 0;

	//Read .obj as text
	for (var i = 0; i < num; ++i)
	{
		var this_line = lines[i];
		if (this_line == "") continue;
		
		var tokens = string_split(this_line, " ");
		//Different types of information in the .obj starts with different headers
		switch tokens[0]
		{
			//Load vertex positions
			case "v":
				V[V_num ++] = [real(tokens[1]), real(tokens[2]), real(tokens[3])];
				break;
			//Load normals
			case "vn":
				N[N_num ++] = [real(tokens[1]), real(tokens[2]), real(tokens[3])];
				break;
			//Load texture coordinates
			case "vt":
				T[T_num ++] = [real(tokens[1]), real(tokens[2])];
				break;
			//Load faces
			case "f":
				var vert_num = array_length(tokens) - 1;
				for (var j = 0; j < vert_num; ++j)
				{
					var info = tokens[j + 1];
					var indices = string_split(info, "/");
					var slashnum = string_count("/", info);
					var doubleslashnum = string_count("//", info);
					
					if (slashnum == 2 && doubleslashnum == 0)
					{	//If the vertex contains a position, texture coordinate and normal
						face_verts[j] = [real(indices[0]) - 1, real(indices[2]) - 1, real(indices[1]) - 1];
					}
					else if (slashnum == 1)
					{	//If the vertex contains a position and a texture coordinate
						face_verts[j] = [real(indices[0]) - 1, 0, real(indices[1]) - 1];
					}
					else if (slashnum == 0)
					{	//If the vertex only contains a position
						face_verts[j] = [real(indices[0]) - 1, 0, 0];
					}
					else if (doubleslashnum == 1)
					{	//If the vertex contains a position and normal
						face_verts[j] = [real(indices[0]) - 1, real(indices[2]) - 1, 0];
					}
				}
				
				//Add vertices in a triangle fan
				for (var j = 0; j <= vert_num - 3; ++j)
				{
					F[F_num ++] = face_verts[0];
					F[F_num ++] = face_verts[j + 2];
					F[F_num ++] = face_verts[j + 1];
				}
				break;
		}
	}
	buffer_delete(buffer);

	//Loop through the loaded information and generate a model
	if (is_array(matrix))
	{
		var normalmatrix = cm_matrix_transpose(cm_matrix_invert_orientation(matrix));
	
		for (var f = 0; f < F_num; f += 3)
		{
			//Add the vertex to the model buffer
			if (smoothnormals)
			{
				var vn = F[f];
				var v1 = V[vn[0]];
				var n1 = N[vn[1]];
				if !is_array(v1){v1 = [0, 0, 0];}
				if !is_array(n1)
				{
					f -= 3;
					smoothnormals = false;
					cm_debug_message("Error in function cm_add_obj: Trying to load an OBJ with smooth normals, but the OBJ format does not contain normals. Loading with flat normals instead.");
					continue;
				}
				var v1 = matrix_transform_vertex(matrix, v1[0], v1[1], v1[2]);
				var n1 = matrix_transform_vertex(normalmatrix, n1[0], n1[1], n1[2], 0);
				var l1 = point_distance_3d(0, 0, 0, n1[0], n1[1], n1[2]);
				n1[0] /= l1; n1[1] /= l1; n1[2] /= l1;
				
				var vn = F[f+1];
				var v2 = V[vn[0]];
				var n2 = N[vn[1]];
				if !is_array(v2){v2 = [0, 0, 0];}
				if !is_array(n2){n2 = [0, 0, 1];}
				var v2 = matrix_transform_vertex(matrix, v2[0], v2[1], v2[2]);
				var n2 = matrix_transform_vertex(normalmatrix, n2[0], n2[1], n2[2], 0);
				var l2 = point_distance_3d(0, 0, 0, n2[0], n2[1], n2[2]);
				n2[0] /= l2; n2[1] /= l2; n2[2] /= l2;
				
				var vn = F[f+2];
				var v3 = V[vn[0]];
				var n3 = N[vn[1]];
				if !is_array(v3){v3 = [0, 0, 0];}
				if !is_array(n3){n3 = [0, 0, 1];}
				var v3 = matrix_transform_vertex(matrix, v3[0], v3[1], v3[2]);
				var n3 = matrix_transform_vertex(normalmatrix, n3[0], n3[1], n3[2], 0);
				var l3 = point_distance_3d(0, 0, 0, n3[0], n3[1], n3[2]);
				n3[0] /= l3; n3[1] /= l3; n3[2] /= l3;
		
				cm_add(container, cm_triangle(singlesided, v1[0], v1[1], v1[2], v2[0], v2[1], v2[2], v3[0], v3[1], v3[2], n1, n2, n3, group));
			}
			else
			{
				var v = V[F[f][0]];
				if !is_array(v){v = [0, 0, 0];}
				var v1 = matrix_transform_vertex(matrix, v[0], v[1], v[2]);
				var v = V[F[f+1][0]];
				if !is_array(v){v = [0, 0, 0];}
				var v2 = matrix_transform_vertex(matrix, v[0], v[1], v[2]);
				var v = V[F[f+2][0]];
				if !is_array(v){v = [0, 0, 0];}
				var v3 = matrix_transform_vertex(matrix, v[0], v[1], v[2]);
		
				cm_add(container, cm_triangle(singlesided, v1[0], v1[1], v1[2], v2[0], v2[1], v2[2], v3[0], v3[1], v3[2], undefined, undefined, undefined, group));
			}
		}
	}
	else
	{
		for (var f = 0; f < F_num; f += 3)
		{
			//Add the vertex to the model buffer
			if (smoothnormals)
			{
				var vn = F[f];
				var v1 = V[vn[0]];
				var n1 = N[vn[1]];
				if !is_array(v1){v1 = [0, 0, 0];}
				if !is_array(n1)
				{
					f -= 3;
					smoothnormals = false;
					continue;
				}
				
				var vn = F[f+1];
				var v2 = V[vn[0]];
				var n2 = N[vn[1]];
				if !is_array(v2){v2 = [0, 0, 0];}
				if !is_array(n2){n2 = [0, 0, 1];}
				
				var vn = F[f+2];
				var v3 = V[vn[0]];
				var n3 = N[vn[1]];
				if !is_array(v3){v3 = [0, 0, 0];}
				if !is_array(n3){n3 = [0, 0, 1];}
		
				cm_add(container, cm_triangle(singlesided, v1[0], v1[1], v1[2], v2[0], v2[1], v2[2], v3[0], v3[1], v3[2], n1, n2, n3, group));
			}
			else
			{
				var v1 = V[F[f][0]];
				if !is_array(v1){v1 = [0, 0, 0];}
				var v2 = V[F[f+1][0]];
				if !is_array(v2){v2 = [0, 0, 0];}
				var v3 = V[F[f+2][0]];
				if !is_array(v3){v3 = [0, 0, 0];}
		
				cm_add(container, cm_triangle(singlesided, v1[0], v1[1], v1[2], v2[0], v2[1], v2[2], v3[0], v3[1], v3[2], undefined, undefined, undefined, group));
			}
		}
	}
	cm_debug_message("Script cm_add_obj: Successfully loaded obj " + string(filename));
	return container;
}