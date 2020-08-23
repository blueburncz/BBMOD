// Set view matrix
var _from = [x, y, z];
var _dcos_up = dcos(direction_up);
var _to = [
	dcos(direction) * _dcos_up,
	-dsin(direction) * _dcos_up,
	dsin(direction_up)
];
var _right = [
	dcos(direction - 90),
	-dsin(direction - 90),
	0
];
var _up = ce_vec3_clone(_to);
ce_vec3_cross(_up, _right);
ce_vec3_add(_to, _from);

matrix_set(matrix_view, matrix_build_lookat(
	_from[0], _from[1], _from[2],
	_to[0], _to[1], _to[2],
	_up[0], _up[1], _up[2]));

bbmod_set_camera_position(_from[0], _from[1], _from[2]);

// Set projection matrix
var _fov = 60;
var _aspect = window_get_width() / window_get_height();
var _znear = 0.1;
var _zfar = 8192;

matrix_set(matrix_projection, matrix_build_projection_perspective_fov(
	_fov, _aspect, _znear, _zfar));

// Render scene
bbmod_material_reset();

matrix_stack_push(matrix_get(matrix_world));
matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, 1000, 1000, 1000));
mod_sphere.render([mat_sky]);
matrix_set(matrix_world, matrix_stack_top());
matrix_stack_pop();

var _model = model[mode_current];
var _material = material[mode_current];

switch (mode_current)
{
case EMode.Normal:
	matrix_stack_push(matrix_get(matrix_world));
	with (OModel)
	{
		matrix_set(matrix_world, matrix_build(x, y, 0, 0, 0, 0, 1, 1, 1));
		_model.render();
	}
	matrix_set(matrix_world, matrix_stack_top());
	matrix_stack_pop();
	break;

case EMode.Static:
	bbmod_static_batch_render(_model, _material)
	break;

case EMode.Dynamic:
	bbmod_dynamic_batch_render(_model, _material, data)
	break;
}

bbmod_material_reset();