var _mat_world = matrix_get(matrix_world);
var _mat_view = matrix_get(matrix_view);
var _mat_proj = matrix_get(matrix_projection);

var _world_transform = matrix_build(0, 0, 0, -90, 0, 0, 1, 1, 1);
var _mat_view = matrix_build_lookat(x, y, z, 0, 0, cam_z, 0, 0, 1);
var _mat_proj = matrix_build_projection_perspective_fov(60, 16 / 9, 0.1, 8192);

matrix_set(matrix_world, _world_transform);
matrix_set(matrix_view, _mat_view);
matrix_set(matrix_projection, _mat_proj);

var _transform = bbmod_get_transform(animation_player);

gpu_push_state();
bbmod_material_reset();
bbmod_render(mod_character, mat_character, _transform);
bbmod_material_reset();

var _mat_right = matrix_multiply(
	matrix_multiply(
		matrix_build(
			weapon_pos[0], weapon_pos[1], weapon_pos[2],
			0, 0, 0,
			1, 1, 1),
		bbmod_get_bone_transform(animation_player, 28)),
	_world_transform);
var _pos_right = matrix_transform_vertex(_mat_right, 0, 0, 0);

var _pos_left;

var _mat_left = matrix_multiply(bbmod_get_bone_transform(animation_player, 9), _world_transform);
_pos_left = matrix_transform_vertex(_mat_left, 0, 0, 0);

ce_vec3_subtract(_pos_left, _pos_right);
ce_vec3_normalize(_pos_left);

var _quat = ce_quaternion_create_look_rotation(_pos_left, [0, 0, 1]);
var _rot = ce_quaternion_to_matrix(_quat);
var _mat_mul = matrix_build(0, 0, 0, weapon_rot[0], weapon_rot[1], weapon_rot[2], 0.4, 0.4, 0.4);

var _mat = matrix_multiply(
	matrix_multiply(_mat_mul, _rot),
	matrix_build(_pos_right[0], _pos_right[1], _pos_right[2], 0, 0, 0, 1, 1, 1));

if (anim_current == anim_reload)
{
	var _mat_mul = matrix_build(0, 0, 0, 11, 0, -90, 0.4, 0.4, 0.4);
	var _mat = matrix_multiply(_mat_mul, _mat_right);
}

matrix_set(matrix_world, _mat);

bbmod_render(mod_m4a1, mat_m4a1);
bbmod_material_reset();
gpu_pop_state();

matrix_set(matrix_world, _mat_world);
matrix_set(matrix_view, _mat_view);
matrix_set(matrix_projection, _mat_proj);