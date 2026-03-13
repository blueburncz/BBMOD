bbmod_set_instance_id(id);

if (ragdoll != undefined && ragdoll.is_active())
{
	ragdoll.get_transform_array(transformArray);
	model.render(undefined, transformArray);
}
else
{
	var _matrix = matrix_build_identity();
	bbmod_matrix_set_translation(_matrix, x, y, z);
	matrix_set(matrix_world, _matrix);

	var _transform = animationPlayer.get_transform();
	model.render(undefined, _transform);

	matrix_set(matrix_world, bbmod_matrix_get_identity());
}

bbmod_set_instance_id(0);
