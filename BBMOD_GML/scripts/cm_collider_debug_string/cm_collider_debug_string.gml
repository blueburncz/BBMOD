// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_collider_debug_string(collider)
{
	return $"[Capsule collider: Mask: {collider[CM.MASK]}, Precision: {collider[CM.PRECISION]}, Slope angle: {collider[CM.SLOPEANGLE]}, R: {collider[CM.R]}, Pos: [{collider[CM.X]}, {collider[CM.Y]}, {collider[CM.Z]}] , Up: [{collider[CM.XUP]}, {collider[CM.YUP]}, {collider[CM.ZUP]}]]";
}