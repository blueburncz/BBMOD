//show_debug_overlay(true);

application_surface_enable(true);
application_surface_draw_enable(false);
application_surface_scale = 2;

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_tex_filter(true);
gpu_set_tex_mip_enable(mip_on);

camera = camera_create();

var _fov = 60;
var _aspect = window_get_width() / window_get_height();
var _znear = 0.1;
var _zfar = 8192;

camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(
	-_fov, -_aspect, _znear, _zfar));

x = 3;
z = 0;
direction = 180;
direction_up = 0;
mouse_last_x = 0;
mouse_last_y = 0;

mod_sphere = new BBMOD_Model("BBMOD/Models/Sphere.bbmod");

#macro TEST_CUBEMAP true

cubemap = new CE_Cubemap(128);

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
	[new BBMOD_Material(BBMOD_ShDefault)],
	new BBMOD_Material(BBMOD_ShDefault),
	new BBMOD_Material(BBMOD_ShDefaultBatched)
];

model = [
	mod_sphere,
	BBMOD_NONE,
	BBMOD_NONE
];

freezed = false;

for (var i = 0; i < BATCH_SIZE; ++i)
{
	var _x = (i mod 8) * 5;
	var _y = (i div 8) * 5;
	instance_create_layer(_x, _y, layer, OModel);
}

#macro TEST_ANIMATIONS true

if (TEST_ANIMATIONS)
{
	character = new BBMOD_Model("Assets/Character.bbmod");
	anim_idle = new BBMOD_Animation("Assets/Idle.bbanim");
	animation_player = new BBMOD_AnimationPlayer(character);
	animation_player.play(anim_idle, true);
	sum = 0;
	times = 0;
}