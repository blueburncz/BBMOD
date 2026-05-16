//This is useful for getting the change in orientation in those cases where the player is standing on a dynamic shape.
//If the player stands on a dynamic shape, its matrix and the inverse of its previous matrix are saved to that queue. This is done in colmesh_dynamic._displaceSphere.
//If the dynamic shape is inside multiple layers of colmeshes, their matrices and inverse previous matrices are also added to the queue.
//These matrices are all multiplied together in this function, resulting in their combined movements gathered in a single matrix.
	
function cm_collider_get_delta_matrix(collider)
{
	var transformations = collider[CM.TRANSFORMATIONS];
	var num = array_length(transformations);
	if (num > 1)
	{
		var i = 0;
		//The first two matrices can simply be multiplied together
		var M = transformations[i++]; //The current world matrix
		var pI = transformations[i++]; //The inverse of the previous world matrix
		var m = matrix_multiply(pI, M);
		repeat (num / 2 - 1)
		{
			//The subsequent matrices need to be multiplied with the target matrix in the correct order
			M = transformations[i++]; //The current world matrix
			pI = transformations[i++]; //The inverse of the previous world matrix
			m = matrix_multiply(matrix_multiply(pI, m), M);
		}
		return m;
	}
	return false;
}