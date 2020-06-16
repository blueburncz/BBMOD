show_debug_overlay(true);

application_surface_enable(true);
application_surface_draw_enable(false);
application_surface_scale = 2;

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_tex_filter(true);

x = 3;
z = 0;
direction = 180;
direction_up = 0;
mouse_last_x = 0;
mouse_last_y = 0;

exposure = 1.0;

spr_sky = sprite_add("Test/Skies/sky.png", 0, false, true, 0, 0);
spr_sky_diffuse = sprite_add("Test/Skies/diffuse.png", 0, false, true, 0, 0);
spr_sky_specular = sprite_add("Test/Skies/specular.png", 0, false, true, 0, 0);

mod_sphere = bbmod_load("Test/Models/Sphere.bbmod");

mat_sky = bbmod_material_create(BBMOD_ShSky,
	sprite_get_texture(spr_sky, 0));
mat_sky[@ BBMOD_EMaterial.OnApply] = shader_sky_on_apply;
mat_sky[@ BBMOD_EMaterial.Culling] = cull_noculling;

model = mod_sphere; //bbmod_load("Test/Models/SportsCar/SportCar.bbmod");

//spr_base_opacity = sprite_add("Test/Models/Monkey/BaseOpacity.png", 0, false, true, 0, 0);
//spr_normal_roughness = sprite_add("Test/Models/Monkey/NormalRoughness.png", 0, false, true, 0, 0);
//spr_metallic_ao = sprite_add("Test/Models/Monkey/MetallicAO.png", 0, false, true, 0, 0);
//spr_subsurface = sprite_add("Test/Models/Monkey/Subsurface.png", 0, false, true, 0, 0);

material = bbmod_material_create(BBMOD_ShDefault);
//material[@ BBMOD_EMaterial.BaseOpacity] = sprite_get_texture(spr_base_opacity, 0);
//material[@ BBMOD_EMaterial.NormalRoughness] = sprite_get_texture(spr_normal_roughness, 0);
//material[@ BBMOD_EMaterial.MetallicAO] = sprite_get_texture(spr_metallic_ao, 0);
//material[@ BBMOD_EMaterial.Subsurface] = sprite_get_texture(spr_subsurface, 0);

//static_batch = bbmod_static_batch_create(bbmod_model_get_vertex_format(model));
//bbmod_static_batch_begin(static_batch);
//for (var i = 0; i < 3; ++i)
//{
//	for (var j = 0; j < 3; ++j)
//	{
//		bbmod_static_batch_add(static_batch, model,
//			matrix_build(
//				i * 5, j * 5, 0,
//				random(360), random(360), random(360),
//				1, 1, 1));
//	}
//}
//bbmod_static_batch_end(static_batch);
//bbmod_static_batch_freeze(static_batch);