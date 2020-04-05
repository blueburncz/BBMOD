show_debug_overlay(true);

gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_tex_filter(true);
gpu_set_cullmode(cull_counterclockwise);

z = 0;
cam_z = 0;
cam_pitch = 0;
cam_zoom = 10;
mouse_last_x = 0;
mouse_last_y = 0;

model = bbmod_load("Demo/Character.bbmod");
ce_assert(model != BBMOD_NONE, "Model loading failed!");

materials = array_create(model[BBMOD_EModel.MaterialCount], BBMOD_MATERIAL_DEFAULT);
animation_player = bbmod_animation_player_create(model);

var _anim_walking = bbmod_load("Demo/Walking.bbanim");
var _anim_sneaking_forward = bbmod_load("Demo/SneakingForward.bbanim");
animations = [
	_anim_walking,
	_anim_sneaking_forward,
];
anim_current = 0;