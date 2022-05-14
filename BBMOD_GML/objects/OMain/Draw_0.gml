draw_clear(c_black);
OPlayer.camera.apply();

if (mouse_check_button_pressed(mb_left))
{
	var _mouseX = window_mouse_get_x();
	var _mouseY = window_mouse_get_y();

	renderer.RenderInstanceIDs = true;
	renderer.render();
	renderer.RenderInstanceIDs = false;

	if (!renderer.select_gizmo(_mouseX, _mouseY))
	{
		show_debug_message(renderer.get_instance_id(_mouseX, _mouseY));
	}
}
else
{
	renderer.render();
}
