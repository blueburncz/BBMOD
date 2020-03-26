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

// TODO: Creat animatio_cache struct!
animation_time_last = 0;
position_key_last = array_create(64, 0);
rotation_key_last = array_create(64, 0);

transform = undefined;

//model = bbmod_load("Demo/bob_lamp_update.bbmod");

//if (model == BBMOD_NONE)
//{
//	show_error("Model loading failed!", true);
//}

//var _spr_body_diffuse = sprite_add("Demo/bob_body.png", 0, 0, 0, 0, 0);
//var _spr_head_diffuse = sprite_add("Demo/bob_head.png", 0, 0, 0, 0, 0);
//var _spr_helmet_diffuse = sprite_add("Demo/bob_helmet.png", 0, 0, 0, 0, 0);
//var _spr_lantern_diffuse = sprite_add("Demo/lantern.png", 0, 0, 0, 0, 0);
//var _spr_lantern_top_diffuse = sprite_add("Demo/lantern_top.png", 0, 0, 0, 0, 0);

//materials = [
//	bbmod_material_create(sprite_get_texture(_spr_body_diffuse, 0)),
//	bbmod_material_create(sprite_get_texture(_spr_head_diffuse, 0)),
//	bbmod_material_create(sprite_get_texture(_spr_helmet_diffuse, 0)),
//	bbmod_material_create(sprite_get_texture(_spr_lantern_diffuse, 0)),
//	bbmod_material_create(sprite_get_texture(_spr_lantern_top_diffuse, 0)),
//];

model = bbmod_load("Demo/Character.bbmod");

if (model == BBMOD_NONE)
{
	show_error("Model loading failed!", true);
}

materials = array_create(model[BBMOD_EModel.MaterialCount], BBMOD_MATERIAL_DEFAULT);

animations = [
	bbmod_load("Demo/Walking.bbanim"),
	bbmod_load("Demo/SneakingForward.bbanim")
];

anim_current = 0;