var _mat_world = matrix_get(matrix_world);
var _mat_view = matrix_get(matrix_view);
var _mat_proj = matrix_get(matrix_projection);

var _world_transform = matrix_build(0, 0, 0, -90, 0, 0, 1, 1, 1);

matrix_set(matrix_world, _world_transform);
matrix_set(matrix_view, matrix_build_lookat(x, y, z, 0, 0, cam_z, 0, 0, 1));
matrix_set(matrix_projection, matrix_build_projection_perspective_fov(60, 16 / 9, 0.1, 8192));

var _transform = bbmod_get_transform(animation_player);

gpu_push_state();
bbmod_material_reset();
bbmod_render(mod_character, mat_character, _transform);
bbmod_material_reset();

var _mat = matrix_multiply(
	matrix_multiply(matrix_build(-12, -2, 0, 15, 0, -90, 0.4, 0.4, 0.4), global.socket),
	_world_transform);
matrix_set(matrix_world, _mat);

bbmod_render(mod_m4a1, mat_m4a1);
bbmod_material_reset();
gpu_pop_state();

matrix_set(matrix_world, _mat_world);
matrix_set(matrix_view, _mat_view);
matrix_set(matrix_projection, _mat_proj);