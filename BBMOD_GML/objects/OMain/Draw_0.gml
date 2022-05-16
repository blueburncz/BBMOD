draw_clear(c_black);
OPlayer.camera.apply();

if (global.editMode && mouse_check_button_pressed(mb_left))
{
	var _mouseX = window_mouse_get_x();
	var _mouseY = window_mouse_get_y();

	renderer.RenderInstanceIDs = true;
	renderer.render();
	renderer.RenderInstanceIDs = false;

	if (renderer.select_gizmo(_mouseX, _mouseY))
	{
		gizmo.IsEditing = true;
	}
	else
	{
		if (!keyboard_check(vk_shift))
		{
			gizmo.clear_selection();
		}

		var _instance = renderer.get_instance_id(_mouseX, _mouseY);
		if (_instance != 0)
		{
			gizmo.toggle_select(_instance);
		}

		var _text = "Selected instances: ";
		var i = 0;
		repeat (ds_list_size(gizmo.Selected))
		{
			_text += string(gizmo.Selected[| i++]) + ", ";
		}
		show_debug_message(_text);
	}
}
else
{
	renderer.render();
}
