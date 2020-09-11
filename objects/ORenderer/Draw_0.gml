camera_apply(camera);

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
		matrix_set(matrix_world,
			matrix_build(x, y, z, 0, 0, image_angle, image_xscale, image_xscale, image_xscale));
		_model.render(_material);
	}
	matrix_set(matrix_world, matrix_stack_top());
	matrix_stack_pop();
	break;

case EMode.Static:
	_model.render(_material);
	break;

case EMode.Dynamic:
	_model.render_object(OModel, _material);
	break;
}

bbmod_material_reset();

if (TEST_ANIMATIONS)
{
	matrix_stack_push(matrix_get(matrix_world));
	matrix_set(matrix_world, matrix_build(-10, -10, 0, -90, 0, 0, 1, 1, 1));
	character.render([mat], animation_player.get_transform());
	matrix_set(matrix_world, matrix_stack_top());
	matrix_stack_pop();

	bbmod_material_reset();
}