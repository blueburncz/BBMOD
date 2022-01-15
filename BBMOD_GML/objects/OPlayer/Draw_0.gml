matrix_set(matrix_world, matrixBody);
animationPlayer.render([matPlayer]);

if (ammo > 0)
{
	matrix_set(matrix_world, matrixGun);
	OMain.modGun.render();
}