// Draw jeep body
var _jeepMatrix = matrix_build(
	jeepX, jeepY, jeepZ,
	0, 0, 90,
	jeepScale, jeepScale, jeepScale
);

var _rigidBodyMatrix = rigidBody.get_matrix().Raw;

var _matrix = matrix_multiply(_jeepMatrix, _rigidBodyMatrix);

matrix_set(matrix_world, _matrix);
jeep.render();

// Draw jeep wheels
var _tireMatrix, _wheelMatrix;

for (var i = 0; i < 4; ++i)
{
	_tireMatrix = matrix_build(
		0, 0, 0,
		0, 0, 90 * ((i == 0 || i == 2) ? -1 : 1),
		jeepScale, jeepScale, jeepScale
	);
	_wheelMatrix = vehicle.get_wheel(i).get_matrix().Raw;
	_wheelMatrix = matrix_multiply(_tireMatrix, _wheelMatrix);
	matrix_set(matrix_world, _wheelMatrix);
	jeepTire.render();

	//if (global.gameSpeed > 0)
	//{
	//	var _inContact = _wheel.is_in_contact();
	//	var _deltaRotation = radtodeg(_wheel.get_delta_rotation());
	//	var _spawnDirt = (_inContact && abs(_deltaRotation) > 2 && random(1) < 0.2) ? 1 : 0;

	//	if (_inContact && !wheelInContact[i])
	//	{
	//		_spawnDirt += 10;
	//	}
	//	wheelInContact[@ i] = _inContact;

	//	var _pos = matrix_transform_vertex(_wheelMatrix, 0, 0, 0);
	//	repeat (_spawnDirt)
	//	{
	//		var _dirtPos = new BBMOD_Vec3().FromArray(_pos);
	//		_dirtPos.X += random_range(-5, 5);
	//		_dirtPos.Y += random_range(-5, 5);
	//		_dirtPos.Z -= 5;
	//		dirtEmitter.spawn_particle(_dirtPos);
	//	}
	//}
}

BBMOD_MATRIX_IDENTITY.ApplyWorld();
