if (keyboard_check(vk_control))
{
	if (keyboard_check_pressed(ord("S")))
	{
		var _buffer = buffer_create(1, buffer_grow, 1);
		bbmod_save_instances_to_buffer(OSaveObject, _buffer);
		buffer_save(_buffer, "save.bin");
		buffer_delete(_buffer);
	}
	else if (keyboard_check_pressed(ord("L")))
	{
		instance_destroy(OSaveObject);
		var _buffer = buffer_load("save.bin");
		bbmod_load_instances_from_buffer(_buffer);
		buffer_delete(_buffer);
	}
	else if (keyboard_check_pressed(ord("N")))
	{
		instance_destroy(OSaveObject);
	}
}
