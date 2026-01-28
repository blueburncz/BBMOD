if (vehicle == undefined)
{
	exit;
}

steering += angle_difference(keyboard_check(vk_right) - keyboard_check(vk_left), steering) * 0.1;

vehicle.set_steering(0, steering);
vehicle.set_steering(1, steering);
vehicle.set_steering(2, 0);
vehicle.set_steering(3, 0);

var _forwad = (keyboard_check(vk_up) - keyboard_check(vk_down)) * 2500 * scale;
vehicle.apply_engine_force(0, _forwad);
vehicle.apply_engine_force(1, _forwad);
//vehicle.apply_engine_force(2, _forwad);
//vehicle.apply_engine_force(3, _forwad);

var _brake = keyboard_check(vk_space) * 5000 * scale;
vehicle.set_brake(0, _brake);
vehicle.set_brake(1, _brake);
vehicle.set_brake(2, _brake);
vehicle.set_brake(3, _brake);

if (mouse_wheel_up() || mouse_wheel_down())
{
	if (keyboard_check(ord("Z")))
	{
		jeepX += 0.01 * (mouse_wheel_up() - mouse_wheel_down());
	}
	//else if (keyboard_check(ord("X")))
	//{
	//	jeepY += 0.01 * (mouse_wheel_up() - mouse_wheel_down());
	//}
	else if (keyboard_check(ord("C")))
	{
		jeepZ += 0.01 * (mouse_wheel_up() - mouse_wheel_down());
	}
	else if (keyboard_check(ord("V")))
	{
		jeepScale += 0.01 * (mouse_wheel_up() - mouse_wheel_down());
	}
	show_debug_message([jeepX, jeepY, jeepZ, jeepScale]);
}
