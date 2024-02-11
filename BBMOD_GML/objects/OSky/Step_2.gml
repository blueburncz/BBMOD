if (lensFlare != undefined)
{
	lensFlare.Position = bbmod_camera_get_position().Add(new BBMOD_Vec3(0, -1000_000, 1000_000));
}

event_inherited();
