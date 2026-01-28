event_inherited();

if (keyboard_check_pressed(vk_f3))
{
	physicsDebug = !physicsDebug;
}

if (physicsDebug)
{
	surface_set_target(renderer.__surFinal);
	camera.apply();
	physicsWorld.draw_debug();
	surface_reset_target();
}
