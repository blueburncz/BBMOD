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

spr_sky = sprite_add("Test/Skies/sky.png", 0, false, true, 0, 0);
spr_ibl = sprite_add("Test/Skies/ibl.png", 0, false, true, 0, 0);

bbmod_set_ibl_sprite(spr_ibl, 0);

mod_sphere = bbmod_load("Test/Models/Sphere.bbmod");

mat_sky = bbmod_material_create(BBMOD_ShSky,
	sprite_get_texture(spr_sky, 0));
mat_sky[@ BBMOD_EMaterial.OnApply] = shader_sky_on_apply;
mat_sky[@ BBMOD_EMaterial.Culling] = cull_noculling;

#macro BATCH_SIZE 64

enum EMode
{
	Normal,
	Static,
	Dynamic,
	SIZE
};

mode_current = EMode.Normal;

material = [
	BBMOD_MATERIAL_DEFAULT,
	BBMOD_MATERIAL_DEFAULT,
	BBMOD_MATERIAL_DEFAULT_BACTHED
];

model = [
	mod_sphere,
	BBMOD_NONE,
	BBMOD_NONE
];

freezed = false;

scales = array_create(BATCH_SIZE, 0);
rotations = array_create(BATCH_SIZE, 0);
data = array_create(BATCH_SIZE * 8, 0);

for (var i = 0; i < BATCH_SIZE; ++i)
{
	var _idx = i * 8;

	var _scale = random_range(0.1, 1);
	scales[i] = _scale;

	var _x = (i mod 8) * 5;
	var _y = (i div 8) * 5;

	instance_create_layer(_x, _y, layer, OModel);

	data[_idx + 0] = _x;
	data[_idx + 1] = _y;
	data[_idx + 2] = 0;
	data[_idx + 3] = _scale;

	var _rot = random(360);
	rotations[i] = _rot;
	var _quat = ce_quaternion_create_from_axisangle([1, 0, 0], _rot);
	array_copy(data, _idx + 4, _quat, 0, 4);
}