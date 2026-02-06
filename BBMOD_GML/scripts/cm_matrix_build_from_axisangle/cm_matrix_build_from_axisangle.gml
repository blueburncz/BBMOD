function cm_matrix_build_from_axisangle(ax, ay, az, angle, targetM = array_create(16)) 
{
	//Get the sin and cos of the angle passed in
	var c = cos(-angle);
	var s = sin(-angle);
	var omc = 1 - c;

	//Nrmalise the input vector
	var l = point_distance_3d(0, 0, 0, ax, ay, az);
	ax /= l;
	ay /= l;
	az /= l;

	//Build the rotation matrix
	targetM[@ 0] = omc * ax * ax + c;
	targetM[@ 1] = omc * ax * ay + s * az;
	targetM[@ 2] = omc * ax * az - s * ay;
	targetM[@ 3] = 0;

	targetM[@ 4] = omc * ax * ay - s * az;
	targetM[@ 5] = omc * ay * ay + c;
	targetM[@ 6] = omc * ay * az + s * ax;
	targetM[@ 7] = 0;

	targetM[@ 8] = omc * ax * az + s * ay;
	targetM[@ 9] = omc * ay * az - s * ax;
	targetM[@ 10] = omc * az * az + c;
	targetM[@ 11] = 0;

	targetM[@ 12] = 0;
	targetM[@ 13] = 0;
	targetM[@ 14] = 0;
	targetM[@ 15] = 1;
	
	return targetM;
}
