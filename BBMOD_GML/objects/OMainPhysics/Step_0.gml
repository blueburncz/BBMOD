event_inherited();

if (keyboard_check_pressed(ord("F")))
{
	var _x = 10;
	var _y = 10;
	var _z = 3;

	with(instance_create_layer(_x, _y, layer, ORagdoll))
	{
		z = _z;
	}
}

if (!physicsPause)
{
	physicsWorld.simulate((1 / 60) * 1, 10);
}
