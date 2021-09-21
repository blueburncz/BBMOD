var _cutscene = GetCutscene();
if (_cutscene)
{
	_cutscene.Update(delta_time);
}

if (keyboard_check_pressed(vk_f1))
{
	debugOverlay = !debugOverlay;
	show_debug_overlay(debugOverlay);
}