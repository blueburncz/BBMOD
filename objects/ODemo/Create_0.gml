gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_tex_filter(true);
gpu_set_cullmode(cull_counterclockwise);

z = 0;
cam_z = 80;
cam_pitch = 25;
direction = 135;
cam_zoom = 200;
mouse_last_x = 0;
mouse_last_y = 0;

mod_m4a1 = bbmod_load("Demo/M4A1.bbmod");
ce_assert(mod_m4a1 != BBMOD_NONE, "Weapon model loading failed!");

var _mat = bbmod_material_create();
_mat[@ BBMOD_EMaterial.Shader] = ShDemo;

mat_m4a1 = array_create(mod_m4a1[BBMOD_EModel.MaterialCount], _mat);

mod_character = bbmod_load("Demo/Character.bbmod");
ce_assert(mod_character != BBMOD_NONE, "Character model loading failed!");

mat_character = array_create(mod_character[BBMOD_EModel.MaterialCount], BBMOD_MATERIAL_DEFAULT);
animation_player = bbmod_animation_player_create(mod_character);

anim_firing = bbmod_load("Demo/FiringRifle.bbanim");
anim_idle = bbmod_load("Demo/IdleAiming.bbanim");
anim_reload = bbmod_load("Demo/Reloading.bbanim");
anim_walk_left = bbmod_load("Demo/WalkLeft.bbanim");
anim_walk_right = bbmod_load("Demo/WalkRight.bbanim");
anim_walk_backward = bbmod_load("Demo/WalkBackward.bbanim");
anim_walk_backward_left = bbmod_load("Demo/WalkBackwardLeft.bbanim");
anim_walk_backward_right = bbmod_load("Demo/WalkBackwardRight.bbanim");
anim_walk_forward = bbmod_load("Demo/WalkForward.bbanim");
anim_walk_forward_left = bbmod_load("Demo/WalkForwardLeft.bbanim");
anim_walk_forward_right = bbmod_load("Demo/WalkForwardRight.bbanim");

anim_current = anim_idle;

bbmod_play(animation_player, anim_current, true);