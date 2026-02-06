event_inherited();

if (keyboard_check(vk_control)
	&& keyboard_check_pressed(ord("M")))
{
	var _path = get_open_filename_ext("BBMOD|*.bbmod", "", working_directory + "assets", "Load a model");
	if (_path != "")
	{
		if (model != undefined)
		{
			model.destroy();
		}
		model = BBMOD_RESOURCE_MANAGER.load_sync(_path).freeze();
		animationPlayer = undefined;
	}
}

if (keyboard_check(vk_control)
	&& keyboard_check_pressed(ord("A"))
	&& model != undefined)
{
	var _path = get_open_filename_ext("BBANIM|*.bbanim", "", working_directory + "assets", "Load an animation");
	if (_path != "")
	{
		var _animation = BBMOD_RESOURCE_MANAGER.load_sync(_path);
		animationPlayer = new BBMOD_AnimationPlayer(model);
		animationPlayer.play(_animation, true);
	}
}

if (animationPlayer != undefined)
{
	animationPlayer.update(delta_time);
}
