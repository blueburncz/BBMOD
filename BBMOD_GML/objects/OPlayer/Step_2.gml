event_inherited();

if (hasGun)
{
	var _dqHand = animationPlayer.get_node_transform(19); // 19 = RightHandIndex1
	var _matrixHand = _dqHand.ToMatrix();
	matrixGun = matrix_multiply(
		matrix_multiply(
			matrix_build(0, 0.1, 0.1, -90, 90, 0, 1, 1, 1),
			_matrixHand),
		matrixBody);
}