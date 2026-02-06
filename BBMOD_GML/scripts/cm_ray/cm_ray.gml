// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
enum CM_RAY
{
	TYPE,
	X,
	Y,
	Z,
	NX,
	NY,
	NZ,
	HIT,
	X1, 
	Y1, 
	Z1, 
	X2,
	Y2,
	Z2,
	OBJECT,
	HITMAP,
	T,
	MASK,
	NUM
}

function cm_ray(x1, y1, z1, x2, y2, z2, mask = -1)
{
	return cm_ray_clear(undefined, x1, y1, z1, x2, y2, z2, mask);
}