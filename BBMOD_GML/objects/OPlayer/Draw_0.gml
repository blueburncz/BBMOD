matrix_set(matrix_world, matrixBody);
animationPlayer.render([matPlayer]);

if (hasGun)
{
	matrix_set(matrix_world, matrixGun);
	OMain.modGun.render();
}