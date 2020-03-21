if (model == B_BBMOD_NONE)
{
	exit;
}

var _mat_world = matrix_get(matrix_world);
var _mat_view = matrix_get(matrix_view);
var _mat_proj = matrix_get(matrix_projection);

matrix_set(matrix_world, matrix_build(0, 0, 0, -90, 0, 0, 1, 1, 1));
matrix_set(matrix_view, matrix_build_lookat(x, y, z, 0, 0, cam_z, 0, 0, 1));
matrix_set(matrix_projection, matrix_build_projection_perspective_fov(60, 16 / 9, 0.1, 8192));

var _shader = ShDemo;
shader_set(_shader);
texture_set_stage(shader_get_sampler_index(_shader, "u_texNormal"),
	sprite_get_texture(SprMaterial, 1));
if (!is_undefined(transform))
{
	shader_set_uniform_f_array(shader_get_uniform(_shader, "u_mBones"), transform);
}
b_bbmod_render(model);
shader_reset();

matrix_set(matrix_world, _mat_world);
matrix_set(matrix_view, _mat_view);
matrix_set(matrix_projection, _mat_proj);