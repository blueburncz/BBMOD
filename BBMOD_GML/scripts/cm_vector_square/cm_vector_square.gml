#macro CM_SQR cm_vector_square
function cm_vector_square(x, y, z)
{
	//Returns the square of the magnitude of the given vector
	return dot_product_3d(x, y, z, x, y, z);
}