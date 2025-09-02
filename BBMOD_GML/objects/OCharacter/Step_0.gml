animationPlayer.update(delta_time);
ui.Update();

if (keyboard_check_pressed(vk_space))
{
	layerWalk.change((layerWalk.Animation == animWalk) ? animRun : animWalk, true);
}
