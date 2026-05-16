function cm_matrix_build(x, y, z, xrotation, yrotation, zrotation, xscale, yscale, zscale)
{
	/*
		This is an alternative to the regular matrix_build.
		The regular function will rotate first and then scale, which can result in weird shearing.
		I have no idea why they did it this way.
		This script does it properly so that no shearing is applied even if you both rotate and scale non-uniformly.
	*/
	var M = matrix_build(x, y, z, xrotation, yrotation, zrotation, 1, 1, 1);
	return cm_matrix_scale(M, xscale, yscale, zscale);
}