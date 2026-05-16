/*
	This function displaces the collider out of the give shape.
*/

function cm_collider_avoid(collider, object, mask = collider[CM.MASK])
{
	return cm_displace(object, collider, mask);
}