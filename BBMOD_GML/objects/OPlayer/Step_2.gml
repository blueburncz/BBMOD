event_inherited();

if (ammo > 0)
{
	var _dqHand = animationPlayer.get_node_transform(19); // 19 = RightHandIndex1
	var _matrixHand = _dqHand.ToMatrix();
	matrixGun = matrix_multiply(
		matrix_multiply(
			matrix_build(0, 0.1, 0.1, -90, 90, 0, 1, 1, 1),
			_matrixHand),
		matrixBody);
}

////////////////////////////////////////////////////////////////////////////////
// Adjust flashlight
flashlight.Enabled = !global.day;

if (flashlight.Enabled
	&& modCharacter.IsLoaded)
{
	var _idHead = modCharacter.find_node_id("Head");
	var _dqHead = animationPlayer.get_node_transform(_idHead);
	var _matrixHead = _dqHead.ToMatrix();
	var _matrixFlashlight = matrix_multiply(
		matrix_multiply(
			matrix_build(0, 0.5, -1, 0, -90, 0, 1, 1, 1),
			_matrixHead),
		matrixBody);
	flashlight.Direction = new BBMOD_Vec4(1.0, -0.25, 0.0, 0.0).Transform(_matrixFlashlight);
	flashlight.Position.Set(_matrixFlashlight[12], _matrixFlashlight[13], _matrixFlashlight[14]);
}
