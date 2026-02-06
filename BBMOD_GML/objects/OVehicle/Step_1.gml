if (vehicle == undefined)
{
	exit;
}

steering += angle_difference(keyboard_check(vk_right) - keyboard_check(vk_left), steering) * 0.1;

vehicle.get_wheel(0).set_steering(steering);
vehicle.get_wheel(1).set_steering(steering);
vehicle.get_wheel(2).set_steering(0);
vehicle.get_wheel(3).set_steering(0);

var _forwad = (keyboard_check(vk_up) - keyboard_check(vk_down)) * 2500 * scale;
vehicle.get_wheel(0).apply_engine_force(_forwad);
vehicle.get_wheel(1).apply_engine_force(_forwad);
//vehicle.get_wheel(2).apply_engine_force(_forwad);
//vehicle.get_wheel(3).apply_engine_force(_forwad);

var _brake = keyboard_check(vk_space) * 5000 * scale;
vehicle.get_wheel(0).set_brake(_brake);
vehicle.get_wheel(1).set_brake(_brake);
vehicle.get_wheel(2).set_brake(_brake);
vehicle.get_wheel(3).set_brake(_brake);

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
