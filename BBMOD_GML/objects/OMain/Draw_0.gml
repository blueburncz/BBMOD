draw_clear(c_black);
OPlayer.camera.apply();

if (global.editMode && mouse_check_button_pressed(mb_left))
{
	var _mouseX = window_mouse_get_x();
	var _mouseY = window_mouse_get_y();
	var _gizmoSelected = renderer.select_gizmo(_mouseX, _mouseY);

	if (_gizmoSelected)
	{
		gizmo.IsEditing = true;
	}
	else
	{
		if (!keyboard_check(vk_shift))
		{
			gizmo.clear_selection();
		}
		renderer.RenderInstanceIDs = true;
	}
	renderer.render();
	renderer.RenderInstanceIDs = false;

	if (!_gizmoSelected)
	{
		var _instance = renderer.get_instance_id(_mouseX, _mouseY);
		if (_instance != 0)
		{
			gizmo.toggle_select(_instance);
		}
	}
}
else
{
	renderer.render();
}
