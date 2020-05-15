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

model = bbmod_load("Test/Models/Cerberus_LP.bbmod");

spr_base_opacity = sprite_add("Test/Models/BaseOpacity.png", 0, false, true, 0, 0);
spr_normal_roughness = sprite_add("Test/Models/NormalRoughness.png", 0, false, true, 0, 0);
spr_metallic_ao = sprite_add("Test/Models/MetallicAO.png", 0, false, true, 0, 0);

material = bbmod_material_create(BBMOD_ShDefault,
	sprite_get_texture(spr_base_opacity, 0),
	sprite_get_texture(spr_normal_roughness, 0),
	sprite_get_texture(spr_metallic_ao, 0));