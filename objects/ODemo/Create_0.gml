gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_cullmode(cull_counterclockwise);

z = 0;
cam_z = 0;
cam_pitch = 0;
cam_zoom = 10;
mouse_last_x = 0;
mouse_last_y = 0;

//model = b_bbmod_load("Demo/box.bbmod");
model = b_bbmod_load_1("Demo/bob_lamp_update.bbmod");
transform = undefined;

if (model == -1)
{
	show_error("Model loading failed!", true);
}