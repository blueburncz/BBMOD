// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_collider_transform(collider, M, invScale)
{
	//Transforms the collider by the given matrix and scale. Useful when transforming between different spaces for collisions with submeshes
	array_copy(collider, CM.X,   matrix_transform_vertex(M, collider[CM.X],				 collider[CM.Y],			  collider[CM.Z]),					0, 3);
	array_copy(collider, CM.XUP, matrix_transform_vertex(M, collider[CM.XUP] * invScale, collider[CM.YUP] * invScale, collider[CM.ZUP] * invScale, 0),  0, 3);
	array_copy(collider, CM.NX,  matrix_transform_vertex(M, collider[CM.NX] * invScale,  collider[CM.NY] * invScale,  collider[CM.NZ] * invScale, 0),   0, 3);
	collider[@ CM.R] /= invScale;
	collider[@ CM.H] /= invScale;
}