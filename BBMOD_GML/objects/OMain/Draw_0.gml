draw_clear(c_black);
OPlayer.camera.apply();

if (mouse_check_button_pressed(mb_left))
{
	renderer.RenderInstanceIDs = true;
	renderer.render();
	show_debug_message(renderer.get_instance_id(window_mouse_get_x(), window_mouse_get_y()));
	renderer.RenderInstanceIDs = false;
}
else
{
	renderer.render();
}
