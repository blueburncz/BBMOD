var _cameraPosition = OPlayer.camera.Position;

matrix_set(matrix_world, matrix_build(
	_cameraPosition.X,
	_cameraPosition.Y,
	_cameraPosition.Z,
	0, 0, current_time,
	1000, 1000, 1000));

modSky.render([matSky]);
