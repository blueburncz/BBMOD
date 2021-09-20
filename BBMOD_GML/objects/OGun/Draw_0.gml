var _scale = 10;
matrix_set(matrix_world,
	matrix_build(
		x, y, z + dsin(current_time * 0.25),
		0, 0, current_time * 0.1,
		_scale, _scale, _scale));
OMain.modGun.render();