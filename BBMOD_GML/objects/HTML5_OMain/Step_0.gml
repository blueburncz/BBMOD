// Enable/disable mouselook
if (mouse_check_button_pressed(mb_any))
{
	camera.set_mouselook(true);
}
else if (keyboard_check_pressed(vk_escape))
{
	camera.set_mouselook(false);
}

// Show/hide cursor based on whether mouselook is enabled/disabled
window_set_cursor(camera.MouseLook ? cr_none : cr_default);

camera.update(delta_time);
animationPlayer.update(delta_time);