bbmod_set_instance_id(id);
new BBMOD_Matrix()
	.Scale(scale)
	.RotateEuler(rotation)
	.Translate(x, y, z)
	.ApplyWorld();
model.render();
