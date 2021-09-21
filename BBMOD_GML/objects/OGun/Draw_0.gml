var _z = z + dsin(current_time * 0.25);
var _direction = current_time * 0.1;
var _scale = 10;
matrix_set(matrix_world,
	matrix_build(x, y, _z, 0, 0, _direction, _scale, _scale, _scale));
OMain.modGun.render();