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

transform = undefined;

model = b_bbmod_load("Demo/bob_lamp_update.bbmod");

if (model == B_BBMOD_NONE)
{
	show_error("Model loading failed!", true);
}

var _spr_body_diffuse = sprite_add("Demo/bob_body.png", 0, 0, 0, 0, 0);
var _mat_body = b_bbmod_material_create(sprite_get_texture(_spr_body_diffuse, 0));
b_bbmod_set_material(model, 0, _mat_body);

var _spr_head_diffuse = sprite_add("Demo/bob_head.png", 0, 0, 0, 0, 0);
var _mat_head = b_bbmod_material_create(sprite_get_texture(_spr_head_diffuse, 0));
b_bbmod_set_material(model, 1, _mat_head);

var _spr_helmet_diffuse = sprite_add("Demo/bob_helmet.png", 0, 0, 0, 0, 0);
var _mat_helmet = b_bbmod_material_create(sprite_get_texture(_spr_helmet_diffuse, 0));
b_bbmod_set_material(model, 2, _mat_helmet);

var _spr_lantern_diffuse = sprite_add("Demo/lantern.png", 0, 0, 0, 0, 0);
var _mat_lantern = b_bbmod_material_create(sprite_get_texture(_spr_lantern_diffuse, 0));
b_bbmod_set_material(model, 3, _mat_lantern);

var _spr_lantern_top_diffuse = sprite_add("Demo/lantern_top.png", 0, 0, 0, 0, 0);
var _mat_lantern_top = b_bbmod_material_create(sprite_get_texture(_spr_lantern_top_diffuse, 0));
b_bbmod_set_material(model, 4, _mat_lantern_top);