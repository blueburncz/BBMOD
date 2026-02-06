function __cmi_triangle_intersects_cube(triangle, hsize, bX, bY, bZ) 
{
	/********************************************************/
	/* AABB-triangle overlap test code                      */
	/* by Tomas Akenine-Möller                              */
	/* Function: int triBoxOverlap(float boxcenter[3],      */
	/*          float boxhalfsize[3],float tri[3][3]); */
	/* History:                                             */
	/*   2001-03-05: released the code in its first version */
	/*   2001-06-18: changed the order of the tests, faster */
	/*                                                      */
	/* Acknowledgement: Many thanks to Pierre Terdiman for  */
	/* suggestions and discussions on how to optimize code. */
	/* Thanks to David Hunt for finding a ">="-bug!         */
	/********************************************************/
	// Source: http://fileadmin.cs.lth.se/cs/Personal/Tomas_Akenine-Moller/pubs/tribox.pdf
	// Modified by Snidr

	/* test in X-direction */
	var v1x = CM_TRIANGLE_X1;
	var v2x = CM_TRIANGLE_X2;
	var v3x = CM_TRIANGLE_X3;
	var d1x = v1x - bX;
	var d2x = v2x - bX;
	var d3x = v3x - bX;
	if (min(d1x, d2x, d3x) > hsize || max(d1x, d2x, d3x) < -hsize){return false;}

	/* test in Y-direction */
	var v1y = CM_TRIANGLE_Y1;
	var v2y = CM_TRIANGLE_Y2;
	var v3y = CM_TRIANGLE_Y3;
	var d1y = v1y - bY;
	var d2y = v2y - bY;
	var d3y = v3y - bY;
	if (min(d1y, d2y, d3y) > hsize || max(d1y, d2y, d3y) < -hsize){return false;}

	/* test in Z-direction */
	var v1z = CM_TRIANGLE_Z1;
	var v2z = CM_TRIANGLE_Z2;
	var v3z = CM_TRIANGLE_Z3;
	var d1z = v1z - bZ;
	var d2z = v2z - bZ;
	var d3z = v3z - bZ;
	if (min(d1z, d2z, d3z) > hsize || max(d1z, d2z, d3z) < -hsize){return false;}
		
	var nx = CM_TRIANGLE_NX;
	var ny = CM_TRIANGLE_NY;
	var nz = CM_TRIANGLE_NZ;
		
	var minx, maxx, miny, maxy, minz, maxz;
	if (nx > 0)
	{
		minx = -hsize;
		maxx = hsize;
	}
	else
	{
		minx = hsize;
		maxx = -hsize;
	}
	if (ny > 0)
	{
		miny = -hsize;
		maxy = hsize;
	}
	else
	{
		miny = hsize;
		maxy = -hsize;
	}
	if (nz > 0)
	{
		minz = -hsize;
		maxz = hsize;
	}
	else
	{
		minz = hsize;
		maxz = -hsize;
	}

	var d = dot_product_3d(d1x, d1y, d1z, nx, ny, nz);
	if (dot_product_3d(minx, miny, minz, nx, ny, nz) > d){return false;}
	if (dot_product_3d(maxx, maxy, maxz, nx, ny, nz) < d){return false;}

	/* Bullet 3:  */
	var fex, fey, fez, p0, p1, p2, ex, ey, ez, rad;
	ex = d2x - d1x;
	ey = d2y - d1y;
	ez = d2z - d1z;
	fex = abs(ex) * hsize;
	fey = abs(ey) * hsize;
	fez = abs(ez) * hsize;
   
	p0 = ez * d1y - ey * d1z;
	p2 = ez * d3y - ey * d3z;
	rad = fez + fey;
	if (min(p0, p2) > rad || max(p0, p2) < -rad){return false;}
   
	p0 = -ez * d1x + ex * d1z;
	p2 = -ez * d3x + ex * d3z;
	rad = fez + fex;
	if (min(p0, p2) > rad || max(p0, p2) < -rad){return false;}
           
	p1 = ey * d2x - ex * d2y;                 
	p2 = ey * d3x - ex * d3y;                 
	rad = fey + fex;
	if (min(p1, p2) > rad || max(p1, p2) < -rad){return false;}

	ex = d3x - d2x;
	ey = d3y - d2y;
	ez = d3z - d2z;
	fex = abs(ex) * hsize;
	fey = abs(ey) * hsize;
	fez = abs(ez) * hsize;
	      
	p0 = ez * d1y - ey * d1z;
	p2 = ez * d3y - ey * d3z;
	rad = fez + fey;
	if (min(p0, p2) > rad || max(p0, p2) < -rad){return false;}
          
	p0 = -ez * d1x + ex * d1z;
	p2 = -ez * d3x + ex * d3z;
	rad = fez + fex;
	if (min(p0, p2) > rad || max(p0, p2) < -rad){return false;}
	
	p0 = ey * d1x - ex * d1y;
	p1 = ey * d2x - ex * d2y;
	rad = fey + fex;
	if (min(p0, p1) > rad || max(p0, p1) < -rad){return false;}

	ex = d1x - d3x;
	ey = d1y - d3y;
	ez = d1z - d3z;
	fex = abs(ex) * hsize;
	fey = abs(ey) * hsize;
	fez = abs(ez) * hsize;

	p0 = ez * d1y - ey * d1z;
	p1 = ez * d2y - ey * d2z;
	rad = fez + fey;
	if (min(p0, p1) > rad || max(p0, p1) < -rad){return false;}

	p0 = -ez * d1x + ex * d1z;
	p1 = -ez * d2x + ex * d2z;
	rad = fez + fex;
	if (min(p0, p1) > rad || max(p0, p1) < -rad){return false;}
	
	p1 = ey * d2x - ex * d2y;
	p2 = ey * d3x - ex * d3y;
	rad = fey + fex;
	if (min(p1, p2) > rad || max(p1, p2) < -rad){return false;}

	return true;
}